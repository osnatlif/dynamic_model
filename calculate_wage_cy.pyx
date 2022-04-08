from libc.math cimport exp as cexp
cimport parameters_cy as p
from draw_husband_cy cimport Husband_cy

cdef calculate_wage_h_cy(Husband_cy husband, double epsilon):
    cdef double tmp1
    cdef double tmp2
    cdef double wage
    # this function calculates husbands actual wage
    tmp1 = (husband.ability_h_value + p.beta10_h*(husband.HE*husband.H_HSD) + p.beta11_h*(husband.HE*husband.H_HSG) + p.beta12_h*(husband.HE*husband.H_SC) + p.beta13_h*(husband.HE*husband.H_CG) + p.beta14_h*(husband.HE*husband.H_PC)
        + p.beta20_h*(husband.HE*husband.H_HSD)**2 + p.beta21_h*(husband.HE*husband.H_HSG)**2 + p.beta22_h*(husband.HE*husband.H_SC)**2 + p.beta23_h*(husband.HE*husband.H_CG)**2 + p.beta24_h*(husband.HE*husband.H_PC)**2
        + p.beta30_h*husband.H_HSD + p.beta31_h*husband.H_HSG + p.beta32_h*husband.H_SC + p.beta33_h*husband.H_CG + p.beta34_h*husband.H_PC)
    tmp2 = epsilon * p.sigma_h_wage
    wage = cexp(tmp1 + tmp2)
    return wage


cdef calculate_wage_w_cy(wife, double w_draw, double epsilon):
    # this function calculates wives actual wage
    cdef double prob_tmp = (p.row0_w*wife.emp_state + p.row11_w*wife.HSG + p.row12_w*wife.SC + p.row13_w*wife.CG + p.row14_w*wife.PC + p.row2_w*wife.WE)
    cdef double prob_w = cexp(prob_tmp)/(1+cexp(prob_tmp))
    cdef double tmp1
    cdef double tmp2
    cdef double wage
    if prob_w > w_draw:
        tmp1 = wife.ability_w_value + p.beta11_w * wife.WE * wife.HSG + p.beta12_w * wife.WE * wife.SC + p.beta13_w * wife.WE * wife.CG + p.beta14_w * wife.WE * wife.PC \
            + p.beta21_w * (wife.WE * wife.HSG)**2 + p.beta22_w * (wife.WE * wife.SC)**2 + p.beta23_w * (wife.WE * wife.CG)**2 + p.beta24_w * (wife.WE * wife.PC)**2 \
            + p.beta31_w * wife.HSG + p.beta32_w * wife.SC + p.beta33_w * wife.CG + p.beta34_w * wife.PC
        tmp2 = epsilon * p.sigma_w_wage
        wage = cexp(tmp1 + tmp2)
        return wage
    else:
        # negative_infinity = float('-inf')
        wage = 0   # should be -inf?
        return wage
