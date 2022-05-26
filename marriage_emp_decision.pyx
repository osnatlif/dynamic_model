cimport constant_parameters as c
from calculate_utility cimport Utility
from draw_husband cimport Husband
from draw_wife cimport Wife


cpdef int wife_emp_decision(Utility utility):       # single women only chooses employment (if she got an offer)
  if utility.wife_s[c.UNEMP] > utility.wife_s[c.EMP]:
    return c.UNEMP
  else:
    return c.EMP


cpdef tuple marriage_emp_decision(Utility utility, double bp, Wife wife, Husband husband, int adjust_bp):
  cdef int M =  c.UNMARRIED
  cdef int max_weighted_utility_index = 0
  cdef double outside_option_w_v = float('-inf')
  cdef double outside_option_h_v = float('-inf')
  cdef double outside_option_w = 0.0

  if utility.wife_s[c.UNEMP] > utility.wife_s[c.EMP]:
    outside_option_w_v = utility.wife_s[c.UNEMP]
    outside_option_w = c.UNEMP
  else:
    outside_option_w_v = utility.wife_s[c.EMP]
    outside_option_w = c.EMP
  outside_option_h_v = utility.husband_s

  if bp == c.NO_BP:
    # no marriage is possible to begin with
    return M, max_weighted_utility_index, outside_option_w_v, outside_option_h_v, outside_option_w

  cdef int BP_FLAG_PLUS = 0
  cdef int BP_FLAG_MINUS = 0

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
      if u_h >= outside_option_h_v and u_w >= outside_option_w_v:
        weighted_utility_both[csi] = u_h*(1.0-bp) + u_w*bp
      elif u_h > outside_option_h_v or u_w > outside_option_w_v:
        weighted_utility_one[csi] = u_h*(1.0-bp) + u_w*bp
    temp = max(weighted_utility_both)
    max_weighted_utility_index = weighted_utility_both.index(temp)
    max_weighted_utility_both = weighted_utility_both[max_weighted_utility_index]
    if max_weighted_utility_both != c.MINIMUM_UTILITY:
      # the max in married for both is better than outside -  no change to bp
      M = c.MARRIED
      employed = max_weighted_utility_index >= c.CS_SIZE
      if employed == c.EMP:
        wife.emp_state = c.EMP
        wife.WE = wife.WE +1
      else:
        wife.emp_state = c.UNEMP
      husband.HE = husband.HE + 1
      return M, max_weighted_utility_index, outside_option_w_v, outside_option_h_v, outside_option_w

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
    if max_U_H >= outside_option_h_v and max_U_W < outside_option_w_v:
      # the outside option is better for wife
      # increase the wife bp
      bp = bp + 0.1
      if bp > 1.0 or BP_FLAG_MINUS == 1:
        # no solution - boundry reached or resolution is not high enough
        break
      BP_FLAG_PLUS = 1
    elif max_U_H < outside_option_h_v and max_U_W >= outside_option_w_v:
      # the outside option is better for husband
      # increase the husband bp
      bp = bp - 0.1
      if bp < 0.0 or BP_FLAG_PLUS == 1:
        # no solution - boundry reached or resolution is not high enough
        break
      BP_FLAG_MINUS = 1
    else:
      print("no adjustment should be done at this point")
  # no marriage
  bp = c.NO_BP
  M = c.UNMARRIED
  if outside_option_w == c.UNEMP:        # unmarried+wife unemployed
    wife.emp_state = c.UNEMP
    return M, max_weighted_utility_index, outside_option_w_v, outside_option_h_v, outside_option_w
  else:                                         # unmarried+wife employed
    wife.emp_state = c.EMP
    wife.WE +=1
  return M, max_weighted_utility_index, outside_option_w_v, outside_option_h_v, outside_option_w
