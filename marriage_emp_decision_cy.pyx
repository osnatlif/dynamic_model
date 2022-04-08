import constant_parameters as c
from calculate_utility_cy cimport Utility_cy
from draw_husband_cy cimport Husband_cy
# import numpy as np


class MarriageEmpDecision:
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


cdef wife_emp_decision_cy(Utility_cy utility):       # single women only chooses employment (if she got an offer)
  if utility.U_W_S[c.UNEMP] > utility.U_W_S[c.EMP]:
    return c.UNEMP
  else:
    return c.EMP


cdef marriage_emp_decision_cy(Utility_cy utility, double bp, wife, Husband_cy husband, int adjust_bp):
  result = MarriageEmpDecision()

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
  max_iterations = c.CS_SIZE

  while True:
    if max_iterations == 0:
      print("max iteration reached. BP=", bp)
    assert bp >= 0.0 and bp <= 1.0
    weighted_utility_both = [float('-inf') for i in range(0, c.CS_SIZE*2)]   # weighted utilities when both has options better than the outside
    weighted_utility_one = [float('-inf') for i in range(0, c.CS_SIZE*2)]  # weighted utilities when only one has option better than the outside
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

    if adjust_bp == False:
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
