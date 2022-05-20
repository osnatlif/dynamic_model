cimport constant_parameters as c
from calculate_utility cimport Utility
from draw_husband cimport Husband
from draw_wife cimport Wife


cdef class MarriageEmpDecision:
  def get_M(self):
    return self.M

  def get_index(self):
    return self.max_weighted_utility_index

  def __init__(self):
    self.M = c.UNMARRIED
    self.max_weighted_utility_index = 0
    self.outside_option_w_v = float('-inf')
    self.outside_option_h_v = float('-inf')
    self.outside_option_w = 0

  def __str__(self):
    return "MarriageEmpDecision:\n\tMarriage: " + str(self.M) + \
           "\n\tMax Index: " + str(self.max_weighted_utility_index) + \
           "\n\tWife's Outside Option: " + str(self.outside_option_w_v) + \
           "\n\tHusband's Outside Option: " + str(self.outside_option_h_v) + \
           "\n\tWife's Employment: " + str(self.outside_option_w)


cpdef int wife_emp_decision(Utility utility):       # single women only chooses employment (if she got an offer)
  if utility.U_W_S[c.UNEMP] > utility.U_W_S[c.EMP]:
    return c.UNEMP
  else:
    return c.EMP


cpdef MarriageEmpDecision marriage_emp_decision(Utility utility, double bp, Wife wife, Husband husband, int adjust_bp):
  cdef MarriageEmpDecision result = MarriageEmpDecision()

  if utility.wife_s[c.UNEMP] > utility.wife_s[c.EMP]:
    result.outside_option_w_v = utility.wife_s[c.UNEMP]
    result.outside_option_w = c.UNEMP
  else:
    result.outside_option_w_v = utility.wife_s[c.EMP]
    result.outside_option_w = c.EMP
  result.outside_option_h_v = utility.husband_s

  if bp == c.NO_BP:
    # no marriage is possible to begin with
    return result
  BP_FLAG_PLUS = False
  BP_FLAG_MINUS = False

  cdef int max_iterations = c.CS_SIZE
  cdef int max_weighted_utility_one_index
  cdef double max_weighted_utility_one
  cdef double max_weighted_utility_both
  cdef double mininf = float('-inf')
  cdef double[22] weighted_utility_both = [mininf, mininf, mininf, mininf, mininf, mininf, mininf, mininf, mininf,  mininf, mininf, \
                                        mininf, mininf, mininf, mininf, mininf, mininf, mininf, mininf, mininf, mininf, mininf]
  cdef double[22] weighted_utility_one = [mininf, mininf, mininf, mininf, mininf, mininf, mininf, mininf, mininf,  mininf, mininf, \
                                        mininf, mininf, mininf, mininf, mininf, mininf, mininf, mininf, mininf, mininf, mininf]
  cdef double u_h
  cdef double u_w
  cdef double max_U_H
  cdef double max_U_W
  cdef double temp
  cdef int i
  cdef int csi

  while True:
    if max_iterations == 0:
      print("max iteration reached. BP=", bp)
    assert bp >= 0.0 and bp <= 1.0
    for i in range(0, c.CS_SIZE*2):
      weighted_utility_both[i] = mininf # weighted utilities when both has options better than the outside
      weighted_utility_one[i] = mininf  # weighted utilities when only one has option better than the outside
    for csi in range(0, c.CS_SIZE*2):
      u_h = utility.husband[csi]
      u_w = utility.wife[csi]
      if u_h >= result.outside_option_h_v and u_w >= result.outside_option_w_v:
        weighted_utility_both[csi] = u_h*(1.0-bp) + u_w*bp
      elif u_h > result.outside_option_h_v or u_w > result.outside_option_w_v:
        weighted_utility_one[csi] = u_h*(1.0-bp) + u_w*bp
    temp = max(weighted_utility_both)
    result.max_weighted_utility_index = weighted_utility_both.index(temp)
    max_weighted_utility_both = weighted_utility_both[result.max_weighted_utility_index]
    if max_weighted_utility_both != c.MINIMUM_UTILITY:
      # the max in married for both is better than outside -  no change to bp
      result.M = c.MARRIED
      employed = result.max_weighted_utility_index >= c.CS_SIZE
      if employed == c.EMP:
        wife.emp_state = c.EMP
        wife.WE = wife.WE +1
      else:
        wife.emp_state = c.UNEMP
      husband.HE = husband.HE + 1
      return result

    if adjust_bp == 0:
      break
    max_iterations = max_iterations - 1
    max_weighted_utility_one = max(weighted_utility_one)
    max_weighted_utility_one_index = weighted_utility_one.index(max_weighted_utility_one)
    if max_weighted_utility_one == c.MINIMUM_UTILITY:
      # the outside option is better for either - no marriage
      break
    max_U_H = utility.husband[max_weighted_utility_one_index]
    max_U_W = utility.wife[max_weighted_utility_one_index]
    # change bp to try and find valid option
    if max_U_H >= result.outside_option_h_v and max_U_W < result.outside_option_w_v:
      # the outside option is better for wife
      # increase the wife bp
      bp = bp + 0.1
      if bp > 1.0 or BP_FLAG_MINUS:
        # no solution - boundry reached or resolution is not high enough
        break
      BP_FLAG_PLUS = True
    elif max_U_H < result.outside_option_h_v and max_U_W >= result.outside_option_w_v:
      # the outside option is better for husband
      # increase the husband bp
      bp = bp - 0.1
      if bp < 0.0 or BP_FLAG_PLUS:
        # no solution - boundry reached or resolution is not high enough
        break
      BP_FLAG_MINUS = True
    else:
      print("no adjustment should be done at this point")
  # no marriage
  bp = c.NO_BP
  result.M = c.UNMARRIED
  if result.outside_option_w == c.UNEMP:        # unmarried+wife unemployed
    wife.emp_state = c.UNEMP
    return result
  else:                                         # unmarried+wife employed
    wife.emp_state = c.EMP
    wife.WE = wife.WE +1
  return result
