import numpy as np
from enum import Enum
cimport constant_parameters as c
from tabulate import tabulate

class Accumulator:
  def __init__(self, dim1, dim2=None):
    if dim2 is not None:
      self.val_arr =  np.zeros((dim1, dim2))
      self.count_arr = np.zeros((dim1, dim2))
    else:
      self.val_arr = np.zeros(dim1)
      self.count_arr = np.zeros(dim1)

  def __str__(self):
    str = ""
    if len(self.val_arr.shape) == 1:
      for i in range(0, self.val_arr.shape[0]):
        if self.count_arr[i] == 0:
          str += "0 "
        else:
          str += str(self.val_arr[i]/self.count_arr[i])
      return str

    for i in range(0, self.val_arr.shape[0]):
      for j in range(0, self.val_arr.shape[1]):
        if self.count_arr[i][j] == 0:
          str += "0 "
        else:
          str += str(self.val_arr[i][j] / self.count_arr[i][j])
      str += "\n"
    return str


  def accumulate(self, value, index1, index2=None):
    if index2 is not None:
      if len(self.val_arr.shape) == 1:
          assert False, 'extra dimension'
      self.val_arr[index1, index2] += value
      self.count_arr[index1, index2] += 1
    else:
      if len(self.val_arr.shape) == 2:
          assert False, 'missing dimension'
      self.val_arr[index1] += value
      self.count_arr[index1] += 1

  def mean(self, index1=None, index2=None):
    if index1 is None:
      return self.val_arr/self.count_arr
    if index2 is not None:
      if len(self.val_arr.shape) == 1:
          assert False, 'extra dimension'
      if self.count_arr[index1, index2] == 0:
        return 0.0
      return self.val_arr[index1, index2]/self.count_arr[index1, index2]
    else:
      if len(self.val_arr.shape) == 1:
        if self.count_arr[index1] == 0:
          return 0.0
        return self.val_arr[index1]/self.count_arr[index1]
      # 2D array - calculating mean over the 1st dimension
      col_count = 0
      col_sum = 0
      for index2 in range(0, self.val_arr.shape[1]):
        col_count += self.count_arr[index1][index2]
        col_sum += self.val_arr[index1][index2]
      if col_count == 0:
        return 0.0
      return col_sum/col_count


class UpDownMomentsType(Enum):
  ability_h_up = 0
  ability_h_eq = 1
  ability_h_down = 2
  ability_w_up = 3
  ability_w_eq = 4
  ability_w_down = 5
  match_w_up = 6
  match_w_eq = 7
  match_w_down = 8
  wages_m_h_up = 9
  wages_m_h_eq = 10
  wages_m_h_down = 11
  emp_m_up_above = 12
  emp_m_up_below = 14
  emp_m_eq_above= 15
  emp_m_eq_below = 16
  emp_m_down_above = 17
  emp_m_down_below = 18
  n_kids_m_arr = 19
  n_kids_um_arr = 20


WAGE_MOM_ROW = 36
WAGE_MOM_COL = 10
MARR_MOM_ROW = c.T_MAX
MARR_MOM_COL = 13
EMP_MOM_ROW = c.T_MAX
EMP_MOM_COL = 13
GEN_MOM_ROW = 31
GEN_MOM_COL = c.SCHOOL_SIZE-1

class EstimatedMoments:
  emp_moments = np.zeros((EMP_MOM_ROW, EMP_MOM_COL))
  marr_fer_moments = np.zeros((MARR_MOM_ROW, MARR_MOM_COL))
  wage_moments = np.zeros((WAGE_MOM_ROW, WAGE_MOM_COL))
  general_moments = np.zeros((GEN_MOM_ROW, GEN_MOM_COL))


class ActualMoments:
  emp_moments = np.loadtxt("emp_moments.txt")
  marr_fer_moments = np.loadtxt("marr_fer_moments.txt")
  wage_moments = np.loadtxt("wage_moments.txt")
  general_moments = np.loadtxt("general_moments.txt")


class Moments:
  bp_initial_dist = np.zeros(10)
  bp_dist = np.zeros(10)
  cs_dist = np.zeros(10)
  emp_total = np.zeros((c.T_MAX, c.SCHOOL_SIZE))      # employment
  count_emp_total = np.zeros((c.T_MAX, c.SCHOOL_SIZE))
  emp_m = np.zeros((c.T_MAX, c.SCHOOL_SIZE))          # employment married
  emp_um = np.zeros((c.T_MAX, c.SCHOOL_SIZE))         # employment unmarried
  emp_m_up = Accumulator(c.SCHOOL_SIZE)             # employment unmarried up
  emp_m_down = Accumulator(c.SCHOOL_SIZE)           # employment unmarried down
  emp_m_eq = Accumulator(c.SCHOOL_SIZE)             # employment unmarried equal
  divorce = np.zeros((c.T_MAX, c.SCHOOL_SIZE))
  just_found_job_m = np.zeros(c.SCHOOL_SIZE)        # transition matrix - unemployment to employment (married)
  just_got_fired_m = np.zeros(c.SCHOOL_SIZE)        # transition matrix - employment to unemployment (married)
  just_found_job_um = np.zeros(c.SCHOOL_SIZE)       # transition matrix - unemployment to employment (unmarried)
  just_found_job_mc = np.zeros(c.SCHOOL_SIZE)       # transition matrix - unemployment to employment (married+kids)
  just_got_fired_um = np.zeros(c.SCHOOL_SIZE)       # transition matrix - unemployment to employment (married+kids)
  just_got_fired_mc = np.zeros(c.SCHOOL_SIZE)       # transition matrix - employment to unemployment (married+kids)
  count_just_got_fired_m = np.zeros(c.SCHOOL_SIZE)
  count_just_found_job_m = np.zeros(c.SCHOOL_SIZE)
  count_just_got_fired_um = np.zeros(c.SCHOOL_SIZE)
  count_just_found_job_um = np.zeros(c.SCHOOL_SIZE)
  count_just_got_fired_mc = np.zeros(c.SCHOOL_SIZE)
  count_just_found_job_mc = np.zeros(c.SCHOOL_SIZE)
  wages_m_h = Accumulator(c.T_MAX, c.SCHOOL_SIZE)   # married men wages - 0 until 20+27 years of exp - 36-c.W_SCHOOL_SIZE7 will be ignored in moments
  wages_w = Accumulator(c.T_MAX, c.SCHOOL_SIZE)     # woman wages if employed
  wages_m_w_up = Accumulator(c.SCHOOL_SIZE)            # married up women wages if employed
  wages_m_w_down = Accumulator(c.SCHOOL_SIZE)          # married down women wages if employed
  wages_m_w_eq = Accumulator(c.SCHOOL_SIZE)            # married equal women wages if employed
  wages_um_w = Accumulator(c.SCHOOL_SIZE)              # unmarried women wages if employed
  married = np.zeros((c.T_MAX, c.SCHOOL_SIZE))      # fertility and marriage rate moments   % married yes/no
  just_married = np.zeros(c.SCHOOL_SIZE)            # for transition matrix from single to married
  just_divorced = np.zeros(c.SCHOOL_SIZE)           # for transition matrix from married to divorce
  age_at_first_marriage = Accumulator(c.SCHOOL_SIZE)   # age at first marriage
  newborn_um = Accumulator((c.T_MAX, c.SCHOOL_SIZE))              # newborn in period t - for probability and distribution
  newborn_m = Accumulator((c.T_MAX, c.SCHOOL_SIZE))               # newborn in period t - for probability and distribution
  newborn_all = Accumulator((c.T_MAX, c.SCHOOL_SIZE))    # newborn in period t - for probability and distribution
  duration_of_first_marriage = Accumulator(c.SCHOOL_SIZE)   # duration of marriage if divorce or c.W_SCHOOL_SIZEc.SCHOOL_SIZE-age of marriage if still married at 45
  assortative_mating_hist  = np.zeros((c.SCHOOL_SIZE, c.SCHOOL_SIZE))    # husband education by wife education
  assortative_mating_count = np.zeros(c.SCHOOL_SIZE)
  count_just_married = np.zeros(c.SCHOOL_SIZE)
  count_just_divorced = np.zeros(c.SCHOOL_SIZE)
  n_kids_arr  = Accumulator(c.SCHOOL_SIZE)   # # of children by school group
  estimated = EstimatedMoments()
  actual = ActualMoments()

  def __init__(self):
    self.emp_m_kids = [Accumulator(c.SCHOOL_SIZE) for a in range(c.KIDS_SIZE)]
    self.emp_um_kids = [Accumulator(c.SCHOOL_SIZE) for a in range(c.KIDS_SIZE)]
    self.up_down_moments = Accumulator(len(UpDownMomentsType), c.SCHOOL_SIZE)


def mean(sum_moment, count_moment, school_group, t=None):
  if t is None:
    if count_moment[school_group] == 0:
      return 0
    return sum_moment[school_group] / count_moment[school_group]

  if count_moment[t][school_group] == 0:
    return 0
  return sum_moment[t][school_group]/count_moment[t][school_group]


def calculate_moments(m, display_moments):
  # calculate employment moments
  for t in range(0, c.T_MAX):
    m.estimated.emp_moments[t][0] = t + 18
    offset = 1
    for school_group in range(1, 5):  # SCHOOL_W_VALUES
      m.estimated.emp_moments[t][offset] = mean(m.emp_total, m.count_emp_total, school_group, t)
      offset += 1
    for school_group in range(1, 5):  #SCHOOL_W_VALUES
      m.estimated.emp_moments[t][offset] = mean(m.emp_m, m.married, school_group, t)
      offset += 1
    for school_group in range(1, 5):  #SCHOOL_W_VALUES
      unmarried = c.DRAW_F - m.married[t][school_group]
      if unmarried == 0:
        m.estimated.emp_moments[t][offset] = 0.0
      else:
        m.estimated.emp_moments[t][offset] = m.emp_um[t][school_group] / unmarried
      offset += 1

    # calculate marriage/fertility moments
    for t in range(0, c.T_MAX):
      m.estimated.marr_fer_moments[t][0] = t + 18
      offset = 1
      for school_group in range(1, 4):  #SCHOOL_W_VALUES
        m.estimated.marr_fer_moments[t][offset] = m.married[t][school_group] / c.DRAW_F
        offset += 1
      for school_group in range(1, 4):  # SCHOOL_W_VALUES
        m.estimated.marr_fer_moments[t][offset] = m.newborn_all.mean(t, school_group)
        offset += 1
      for school_group in range(1, 4):  #SCHOOL_W_VALUES
        m.estimated.marr_fer_moments[t][offset] = m.divorce[t][school_group] / c.DRAW_F
        offset += 1

    # calculate wage moments
    for t in range(0, c.T_MAX):
      m.estimated.wage_moments[t][0] = t
      offset = 1
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.wage_moments[t][offset] = m.wages_w.mean(t, WS)
        offset += 1
      for HS in range(0, 5):  # SCHOOL_H_VALUES
        m.estimated.wage_moments[t][offset] = m.wages_m_h.mean(t, HS)
        offset += 1
      # calculate general moments
      # assortative mating
      row = 0
      for HS in range(0, 5):  # SCHOOL_H_VALUES
        count = m.assortative_mating_count[HS]
        for WS in range(1, 5):  # SCHOOL_W_VALUES
          if count == 0:
            m.estimated.general_moments[row][WS - 1] = 0.0
          else:
            m.estimated.general_moments[row][WS - 1] = m.assortative_mating_hist[WS][HS] / count
        row += 1
      # first marriage duration
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.general_moments[row][WS - 1] = m.duration_of_first_marriage.mean(WS)
      row += 1
      # age at first marriage
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.general_moments[row][WS - 1] = m.age_at_first_marriage.mean(WS)
      row += 1
      # kids
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.general_moments[row][WS - 1] = m.n_kids_arr.mean(WS)
      row += 1
      # women wage by match: UP, EQUAL, DOWN
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.general_moments[row][WS - 1] = m.wages_m_w_up.mean(WS)
      row += 1
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.general_moments[row][WS - 1] = m.wages_m_w_eq.mean(WS)
      row += 1
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.general_moments[row][WS - 1] = m.wages_m_w_down.mean(WS)
      row += 1
      # employment by match: UP, EQUAL, DOWN
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.general_moments[row][WS - 1] = m.emp_m_up.mean(WS)
      row += 1
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.general_moments[row][WS - 1] = m.emp_m_eq.mean(WS)
      row += 1
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.general_moments[row][WS - 1] = m.emp_m_down.mean(WS)
      row += 1
      # employment by children: married with 0 - 4+ kids, unmarried with kids, unmarried with no kids
      for kids_n in range(0, c.KIDS_SIZE):
        for WS in range(1, 5):  # SCHOOL_W_VALUES
          m.estimated.general_moments[row][WS - 1] = m.emp_m_kids[kids_n].mean(WS)
        row += 1
      for kids_n in range(0, 2):
        for WS in range(1, 5):  # SCHOOL_W_VALUES
          m.estimated.general_moments[row][WS - 1] = m.emp_um_kids[kids_n].mean(WS)
        row += 1
      # employment transition matrix:
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.general_moments[row][WS - 1] = mean(m.just_got_fired_m, m.count_just_got_fired_m, WS)
      row += 1
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.general_moments[row][WS - 1] = mean(m.just_found_job_m, m.count_just_found_job_m, WS)
      row += 1
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.general_moments[row][WS - 1] = mean(m.just_got_fired_um, m.count_just_got_fired_um, WS)
      row += 1
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.general_moments[row][WS - 1] = mean(m.just_found_job_um, m.count_just_found_job_um, WS)
      row += 1
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.general_moments[row][WS - 1] = mean(m.just_got_fired_mc, m.count_just_got_fired_mc, WS)
      row += 1
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.general_moments[row][WS - 1] = mean(m.just_found_job_mc, m.count_just_found_job_mc, WS)
      row += 1
      # marriage transition matrix
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.general_moments[row][WS - 1] = mean(m.just_married, m.count_just_married, WS)
      row += 1
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.general_moments[row][WS - 1] = mean(m.just_divorced, m.count_just_divorced, WS)
      row += 1
      # birth rate unmarried and married
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.general_moments[row][WS - 1] = m.newborn_um.mean(WS)
      row += 1
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        m.estimated.general_moments[row][WS - 1] = m.newborn_m.mean(WS)

    if display_moments:

      up_down_mom_description = ["Married Up - Men's Ability",
                                 "Married Equal - Men's Ability",
                                 "Married Down - Men's Ability",
                                 "Married Up - Women's Ability",
                                 "Married Equal - Women's Ability",
                                 "Married Down - Women's Ability",
                                 "Married Up - Match Quality",
                                 "Married Equal - Match Quality",
                                 "Married Down - Match Quality",
                                 "Married Up - Men's Wage",
                                 "Married Equal - Men's Wage",
                                 "Married Down - Men's Wage",
                                 "Emp of Married Up - Men's Wage Above",
                                 "Emp of Married Up - Men's Wage Below",
                                 "Emp of Married Equal - Men's Wage Above",
                                 "Emp of Married Equal - Men's Wage Below",
                                 "Emp of Married Down - Men's Wage Above",
                                 "Emp of Married Down - Men's Wage Below",
                                 "# Kids for Married Women",
                                 "# Kids for Unmarried Women"]

      print("\nUp/Down Moments")
      headers = ["Moment Name", "HSD", "HSG", "SC", "CG", "PC"]
      table = tabulate(np.concatenate((np.array([up_down_mom_description]).T, m.up_down_moments.mean()), axis=1), headers, floatfmt=".2f", tablefmt="simple")
      print(table)

      print("\nBargaining Power and Consumption Share Distribution")
      dist_sum = np.sum(m.bp_initial_dist)
      print(m.bp_initial_dist / dist_sum)
      dist_sum = np.sum(m.bp_dist)
      print(m.bp_dist / dist_sum)
      dist_sum = np.sum(m.cs_dist)
      print(m.cs_dist / dist_sum)

      print("\nWage Moments - Married Women")
      headers = ["HSD", "HSG", "SC", "CG", "PC", "HSD", "HSG", "SC", "CG", "PC",]
      table = tabulate(np.concatenate((m.estimated.wage_moments[:, 0:4], m.actual.wage_moments[:, 0:4]), axis=1), headers, floatfmt=".2f", tablefmt="simple")
      print(table)
      print("\nWage Moments - Married Men")
      table = tabulate(np.concatenate((m.estimated.wage_moments[:, 4:9], m.actual.wage_moments[:, 4:9]), axis=1), headers, floatfmt=".2f", tablefmt="simple")
      print(table)

      print("\nEmployment Moments - Total Women")
      print(np.concatenate((m.estimated.emp_moments[:, 0:4], m.actual.emp_moments[:, 0:4]), axis=1))
      print("\nEmployment Moments - Married Women")
      print(np.concatenate((m.estimated.emp_moments[:, 4:8], m.actual.emp_moments[:, 4:8]), axis=1))
      print("\nEmployment Moments - Unmarried Women")
      print(np.concatenate((m.estimated.emp_moments[:, 8:12], m.actual.emp_moments[:, 8:12]), axis=1))

      print("\nMarriage Rate")
      print(np.concatenate((m.estimated.marr_fer_moments[:, 0:4], m.actual.marr_fer_moments[:, 0:4]), axis=1))
      print("\nFertility Rate")
      print(np.concatenate((m.estimated.marr_fer_moments[:, 4:8], m.actual.marr_fer_moments[:, 4:8]), axis=1))
      print("\nDivorce Rate")
      print(np.concatenate((m.estimated.marr_fer_moments[:, 8:12], m.actual.marr_fer_moments[:, 8:12]), axis=1))
      gen_mom_description = ["Assortative Mating - HSD",
                             "Assortative Mating - HSG",
                             "Assortative Mating - SC",
                             "Assortative Mating - CG",
                             "Assortative Mating - PC",
                             "Marriage Duration",
                             "Age at 1st Marriage",
                             "Kids",
                             "Wage - Married Up",
                             "Wage - Married Equal",
                             "Wage - Married Down",
                             "Emp - Married Up",
                             "Emp - Married Equal",
                             "Emp - Married Down",
                             "Emp - Married No kids",
                             "Emp - Married 1 kid",
                             "Emp - Married 2 kids",
                             "Emp - Married 3 kids",
                             "Emp - Married 4+ kids",
                             "Emp - Unmarried No kids",
                             "Emp - Unmarried 1+ kid",
                             "Emp->Unemp - Married",
                             "Unemp->Emp - Married",
                             "Emp->Unemp - Unmarried",
                             "Unemp->Emp - Unmarried",
                             "Emp->Unemp - Married+",
                             "Unemp->Emp - Married+",
                             "Unmarried->Married",
                             "Married->Unmarried",
                             "Birth Rate - Married",
                             "Birth Rate - Unarried"]
      print("\n")
      headers = ["Moment Name", "HSG", "SC", "CG", "PC", "HSG", "SC", "CG", "PC", ]
      table = tabulate(np.concatenate((np.array([gen_mom_description]).T, m.estimated.general_moments, m.actual.general_moments), axis=1), headers, floatfmt=".2f", tablefmt="simple")
      print(table)

      return m
