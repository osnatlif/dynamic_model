from libc.math cimport pow as cpow
import numpy as np
cimport parameters_cy as p
from value_to_index_cy cimport exp_to_index_cy
from value_to_index_cy cimport bp_to_index_cy
from gross_to_net_cy cimport gross_to_net_cy
from gross_to_net_cy cimport NetIncome_cy
cimport constant_parameters_cy as c
from draw_husband_cy cimport Husband_cy
from draw_wife_cy cimport Wife_cy

cdef class Utility_cy:
  def __init__(self):
    #self.wife = [float('-inf') for i in range(0, c.CS_SIZE * 2)]
    self.wife = np.empty(c.CS_SIZE * 2)
    self.husband = np.empty(c.CS_SIZE * 2)
    self.wife_s = np.empty(2)
    self.husband_s = 0.0
    self.reset()

  def __str__(self):
    return "Utility:\n\tMarried Woman: " + str(self.wife) + \
           "\n\tMarried Man: " + str(self.husband) + \
           "\n\tSingle Woman: " + str(self.wife_s) + \
           "\n\tSingle Man: " + str(self.husband_s)

  cdef reset(self):
    cdef int i
    for i in range (0, c.CS_SIZE * 2):
      self.wife[i] = float('-inf')
      self.husband[i] = float('-inf')
    self.wife_s[0] = float('-inf')
    self.wife_s[1] = float('-inf')
    self.husband_s = float('-inf')


cdef Utility_cy calculate_utility_cy(
        double[:,:,:,:,:,:,:,:,:,:] w_emax,
        double[:,:,:,:,:,:,:,:,:,:]h_emax,
        double[:,:,:,:,:,:] w_s_emax,
        double[:,:,:] h_s_emax,
        int kids,
        double wage_h,
        double wage_w,
        int choose_partner,
        int M,
        Wife_cy wife,
        Husband_cy husband,
        int t,
        double BP,
        int single_men):
  cdef int T_END
  cdef int age_index
  cdef int i
  if single_men:
    T_END = husband.T_END
    age_index = husband.age_index
  else:
    T_END = wife.T_END
    age_index = wife.age_index

  assert t <= T_END
  cdef NetIncome_cy net = gross_to_net_cy(kids, wage_w, wage_h, t, age_index)
  cdef Utility_cy result = Utility_cy()
  cdef int kids_h = c.NO_KIDS
  cdef double CS
  cdef double UC_W1
  cdef double UC_W2
  cdef double UC_H1
  cdef double UC_H2
  cdef double total_cons_denom
  cdef double total_cons1
  cdef double total_cons2
  cdef double women_cons_m1
  cdef double women_cons_m2
  cdef double men_cons_m1
  cdef double men_cons_m2
  cdef int exp_wi
  cdef int BPi

  if M == c.MARRIED or choose_partner:
    kids_h = kids
    # decision making -choose from up to 6 options, according to CHOOSE_HUSBAND and CHOOSE_WORK_H, CHOOSE_WORK_W  values
    # utility from each option:
    # home production technology - parameters
    # global hp sigma CRRA parameter
    # eqvivalent scale = 1 kids*0.3;

    for i in range(0, c.CS_SIZE):             # consumption share grid
      CS = c.cs_vector[i]
      total_cons_denom = cpow(cpow(CS, p.hp)+cpow(1.0-CS, p.hp), 1.0/p.hp)*(1.0+kids*0.3)
      total_cons1 = net.net_income_m_unemp/total_cons_denom   # only men employed
      total_cons2 = net.net_income_m/total_cons_denom       # both employed
      women_cons_m1 = CS*total_cons1          # women private consumption when married and unemployed
      women_cons_m2 = CS*total_cons2          # women private consumption when married and employed
      men_cons_m1 = (1.0-CS)*total_cons1    # men private consumption when married and women unemployed
      men_cons_m2 = (1.0-CS)*total_cons2    # men private consumption when married and women employed
      UC_W1 = cpow(women_cons_m1, p.alpha)/p.alpha + p.alpha1_w_m*kids + wife.Q + wife.similar_educ + p.alpha2_w*np.log1p(kids) + p.alpha3_w
      UC_W2 = cpow(women_cons_m2, p.alpha)/p.alpha + p.alpha1_w_m*kids + wife.Q + wife.similar_educ
      UC_H1 = cpow(men_cons_m1, p.alpha)/p.alpha + p.alpha1_h_m*kids + wife.Q + wife.similar_educ
      UC_H2 = cpow(men_cons_m2, p.alpha)/p.alpha + p.alpha1_h_m*kids + wife.Q + wife.similar_educ
      if t == T_END:
        # t1 schooling wife - HSG, t2 schooling wife - SC, t3 schooling wife - CG, t4 schooling wife - PC, t5 exp wife
        # t6 schooling husband if married - HSD, t7 schooling husband - HSG, t8 Shooling husband - SC, t9 Schooling husband CG, t10 schooling husband - PC
        # t11 exp husband if married, t12 martial status, t13 number of children, t14 match quality if married, t15 number of children if married
        # t16 previous work state - wife
        # first calculate the value of husband employed women unemployed
        result.wife[i] = (UC_W1+p.t1_w*wife.HSG+p.t2_w*wife.SC+p.t3_w*wife.CG+p.t4_w*wife.PC+p.t5_w*wife.WE
          + p.t6_w*husband.H_HSD+p.t7_w*husband.H_HSG+p.t8_w*husband.H_SC+p.t9_w*husband.H_CG+p.t10_w*husband.H_PC
          + p.t11_w*(husband.HE+1.0)+p.t12_w+p.t13_w*kids+p.t14_w*(wife.Q+wife.similar_educ)+p.t15_w*kids)

        result.husband[i] = (UC_H1 + p.t1_h * wife.HSG + p.t2_h * wife.SC + p.t3_h * wife.CG + p.t4_h * wife.PC + p.t5_h * wife.WE
          + p.t6_h * husband.H_HSD + p.t7_h * husband.H_HSG + p.t8_h * husband.H_SC + p.t9_h * husband.H_CG + p.t10_h * husband.H_PC
          + p.t11_h * (husband.HE + 1.0) + p.t12_h + p.t13_h * kids + p.t14_h * (wife.Q + wife.similar_educ))
        # calculate the value of both working only if women got a job offer
        if wage_w > 0:
          result.wife[c.CS_SIZE+i] = (UC_W2+p.t1_w*wife.HSG+p.t2_w*wife.SC+p.t3_w*wife.CG+p.t4_w*wife.PC+p.t5_w*(wife.WE+1.0)
            + p.t6_w*husband.H_HSD+p.t7_w*husband.H_HSG+p.t8_w*husband.H_SC+p.t9_w*husband.H_CG+p.t10_w*husband.H_PC
            + p.t11_w*(husband.HE+1.0)+p.t12_w+p.t13_w*kids+p.t14_w*(wife.Q+wife.similar_educ)+p.t15_w*kids+p.t16_w)

          result.husband[c.CS_SIZE+i] = (UC_H2+p.t1_h*wife.HSG+p.t2_h*wife.SC+p.t3_h*wife.CG+p.t4_h*wife.PC+p.t5_h*(wife.WE+1.0)
            + p.t6_h*husband.H_HSD+p.t7_h*husband.H_HSG+p.t8_h*husband.H_SC+p.t9_h*husband.H_CG+p.t10_h*husband.H_PC
            + p.t11_h*(husband.HE+1.0)+p.t12_h+p.t13_h*kids+p.t14_h*(wife.Q+wife.similar_educ)+p.t16_h)
      elif t < T_END:
        # the loop goes from 28 to 1, but for SC, CG and PC the loop is shorter
        exp_wi = exp_to_index_cy(wife.WE)
        BPi = bp_to_index_cy(BP)
        result.wife[i] = UC_W1 + c.beta0*w_emax[t+1][exp_wi][kids][c.UNEMP][wife.ability_wi][husband.ability_hi][husband.HS][wife.WS][wife.Q_INDEX][BPi]
        result.husband[i] = UC_H1 + c.beta0*h_emax[t+1][exp_wi][kids][c.UNEMP][wife.ability_wi][husband.ability_hi][husband.HS][wife.WS][wife.Q_INDEX][BPi]
        exp_wi = exp_to_index_cy(wife.WE+1)
        if wage_w > 0:
          result.wife[c.CS_SIZE+i] = UC_W2 + c.beta0*w_emax[t+1][exp_wi][kids][c.EMP][wife.ability_wi][husband.ability_hi][husband.HS][wife.WS][wife.Q_INDEX][BPi]
          result.husband[c.CS_SIZE+i] = UC_H2 + c.beta0*h_emax[t+1][exp_wi][kids][c.EMP][wife.ability_wi][husband.ability_hi][husband.HS][wife.WS][wife.Q_INDEX][BPi]

  cdef double UC_W_S_UNEMP = p.alpha1_w_s*kids + p.alpha2_w*np.log1p(kids) + p.alpha3_w
  cdef double women_cons_s2
  cdef double UC_W_S_EMP

  if wage_w > 0:
    women_cons_s2 = net.net_income_s_w/(1.0+kids*0.3)    # women private consumption when single and employed
    UC_W_S_EMP = cpow(women_cons_s2, p.alpha)/p.alpha + p.alpha1_w_s*kids
    if t == T_END:
      result.wife_s[c.EMP] = (UC_W_S_EMP + p.t1_w * wife.HSG + p.t2_w * wife.SC + p.t3_w * wife.CG + p.t4_w * wife.PC + p.t5_w * (
                wife.WE + 1.0) + p.t13_w * kids + p.t16_w)
    else:
      exp_wi = exp_to_index_cy(wife.WE)
      result.wife_s[c.EMP] = UC_W_S_EMP + c.beta0*w_s_emax[t+1][exp_wi][kids][c.EMP][wife.ability_wi][wife.WS]

  cdef double UC_H_S = cpow(net.net_income_s_h, p.alpha)/p.alpha
  if t == T_END:
    result.wife_s[c.UNEMP] = UC_W_S_UNEMP+p.t1_w*wife.HSG+p.t2_w*wife.SC+p.t3_w*wife.CG+p.t4_w*wife.PC+p.t5_w*wife.WE +p.t13_w*kids
    result.husband_s = UC_H_S+p.t6_h*husband.H_HSD+p.t7_h*husband.H_HSG+p.t8_h*husband.H_SC+p.t9_h*husband.H_CG+p.t10_h*husband.H_PC+p.t11_h*(husband.HE+1.0)+p.t13_h*kids_h
  else:
    exp_wi = exp_to_index_cy(wife.WE)
    result.wife_s[c.UNEMP] = UC_W_S_UNEMP + c.beta0*w_s_emax[t+1][exp_wi][kids][c.UNEMP][wife.ability_wi][wife.WS]
    result.husband_s = UC_H_S + c.beta0*h_s_emax[t+1][husband.ability_hi][husband.HS]

  return result
