import numpy as np
from enum import Enum
cimport constant_parameters as c


class Accumulator:
  def __init__(self, dim1, dim2=None):
    if dim2 is not None:
      self.val_arr =  np.zeros((dim1, dim2))
      self.count_arr = np.zeros((dim1, dim2))
    else:
      self.val_arr = np.zeros(dim1)
      self.count_arr = np.zeros(dim1)

  def accumulate(self, value, index1, index2=None):
    if index2 is not None:
      self.val_arr[index1, index2] += value
      self.count_arr[index1, index2] += 1
    else:
      self.val_arr[index1] += value
      self.count_arr[index1] += 1

  def mean(self, index1, index2=None):
    if index2 is not None:
      if self.count_arr[index1, index2] == 0:
        return 0.0
      return self.val_arr[index1, index2]/self.count_arr[index1, index2]
    else:
      if self.count_arr[index1] == 0:
        return 0.0
      return self.val_arr[index1]/self.count_arr[index1]


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

class EstimatedMoments:
  up_down_moments = Accumulator(len(UpDownMomentsType), c.SCHOOL_SIZE)

class Moments:
  bp_initial_dist = np.zeros(10)
  bp_dist = np.zeros(10)
  cs_dist = np.zeros(10)
  emp_total = np.zeros((c.T_MAX, c.W_SCHOOL_SIZE))      # employment
  count_emp_total = np.zeros((c.T_MAX, c.W_SCHOOL_SIZE))
  emp_m = np.zeros((c.T_MAX, c.W_SCHOOL_SIZE))          # employment married
  emp_um = np.zeros((c.T_MAX, c.W_SCHOOL_SIZE))         # employment unmarried
  emp_m_up = Accumulator(c.W_SCHOOL_SIZE)             # employment unmarried up
  emp_m_down = Accumulator(c.W_SCHOOL_SIZE)           # employment unmarried down
  emp_m_eq = Accumulator(c.W_SCHOOL_SIZE)             # employment unmarried equal
  divorce = np.zeros((c.T_MAX, c.W_SCHOOL_SIZE))
  just_found_job_m = np.zeros(c.W_SCHOOL_SIZE)        # transition matrix - unemployment to employment (married)
  just_got_fired_m = np.zeros(c.W_SCHOOL_SIZE)        # transition matrix - employment to unemployment (married)
  just_found_job_um = np.zeros(c.W_SCHOOL_SIZE)       # transition matrix - unemployment to employment (unmarried)
  just_found_job_mc = np.zeros(c.W_SCHOOL_SIZE)       # transition matrix - unemployment to employment (married+kids)
  just_got_fired_um = np.zeros(c.W_SCHOOL_SIZE)       # transition matrix - unemployment to employment (married+kids)
  just_got_fired_mc = np.zeros(c.W_SCHOOL_SIZE)       # transition matrix - employment to unemployment (married+kids)
  count_just_got_fired_m = np.zeros(c.W_SCHOOL_SIZE)
  count_just_found_job_m = np.zeros(c.W_SCHOOL_SIZE)
  count_just_got_fired_um = np.zeros(c.W_SCHOOL_SIZE)
  count_just_found_job_um = np.zeros(c.W_SCHOOL_SIZE)
  count_just_got_fired_mc = np.zeros(c.W_SCHOOL_SIZE)
  count_just_found_job_mc = np.zeros(c.W_SCHOOL_SIZE)
  wages_m_h = Accumulator(c.T_MAX, c.SCHOOL_SIZE)   # married men wages - 0 until 20+27 years of exp - 36-c.W_SCHOOL_SIZE7 will be ignored in moments
  wages_w = Accumulator(c.T_MAX, c.W_SCHOOL_SIZE)     # woman wages if employed
  wages_m_w_up = np.zeros(c.W_SCHOOL_SIZE)            # married up women wages if employed
  wages_m_w_down = np.zeros(c.W_SCHOOL_SIZE)          # married down women wages if employed
  wages_m_w_eq = np.zeros(c.W_SCHOOL_SIZE)            # married equal women wages if employed
  wages_um_w = np.zeros(c.W_SCHOOL_SIZE)              # unmarried women wages if employed
  married = np.zeros((c.T_MAX, c.W_SCHOOL_SIZE))         # fertility and marriage rate moments   % married yes/no
  just_married = np.zeros(c.W_SCHOOL_SIZE)            # for transition matrix from single to married
  just_divorced = np.zeros(c.W_SCHOOL_SIZE)           # for transition matrix from married to divorce
  age_at_first_marriage = np.zeros(c.W_SCHOOL_SIZE)   # age at first marriage
  newborn_um = np.zeros(c.W_SCHOOL_SIZE)              # newborn in period t - for probability and distribution
  newborn_m = np.zeros(c.W_SCHOOL_SIZE)               # newborn in period t - for probability and distribution
  newborn_all = np.zeros(c.W_SCHOOL_SIZE)             # newborn in period t - for probability and distribution
  duration_of_first_marriage = np.zeros(c.W_SCHOOL_SIZE)   # duration of marriage if divorce or c.W_SCHOOL_SIZEc.SCHOOL_SIZE-age of marriage if still married at 45
  assortative_mating_hist  = np.zeros((c.SCHOOL_SIZE, c.SCHOOL_SIZE))    # husband education by wife education
  assortative_mating_count = np.zeros(c.W_SCHOOL_SIZE)
  count_just_married = np.zeros(c.W_SCHOOL_SIZE)
  count_just_divorced = np.zeros(c.W_SCHOOL_SIZE)
  n_kids_arr  = np.zeros(c.W_SCHOOL_SIZE)   # # of children by school group
  estimated = EstimatedMoments()

  def __init__(self):
    self.emp_m_kids = [Accumulator(c.W_SCHOOL_SIZE) for a in range(c.MAX_NUM_KIDS)]
    self.emp_um_kids = [Accumulator(c.W_SCHOOL_SIZE) for a in range(c.MAX_NUM_KIDS)]


def calculate_moments(m, display_moments):
    x=1


