cimport constant_parameters_cy as c
from calculate_utility_cy cimport Utility_cy
import numpy as np


# find the BP value that has the maximum nash value
cdef double nash_cy(Utility_cy utility):
  # return 0.5    -    if you want a constant bp of 0.5 - remove comment
  # marriage decision - outside option value wife
  cdef double outside_option_w_v = max(utility.wife_s[c.UNEMP], utility.wife_s[c.EMP])
  cdef double outside_option_h_v = utility.husband_s
  cdef temp = np.ones(c.CS_SIZE*2)
  cdef double max_nash_value = c.MINIMUM_UTILITY
  cdef int max_nash_index = 0
  cdef double nash_value
  cdef int i
  # leave only positive surplus for both
  for i in range(0, c.UTILITY_SIZE):
    if utility.wife[i] > outside_option_w_v and utility.husband[i] > outside_option_h_v:
      # if positive surplus for both
      nash_value = (utility.wife[i]-outside_option_w_v)**0.5 * (utility.husband[i]-outside_option_h_v)**0.5
      if nash_value > max_nash_value:
        max_nash_value = nash_value
        max_nash_index = i

  if max_nash_value == c.MINIMUM_UTILITY:
    return c.NO_BP

  return c.bp_vector[max_nash_index % c.CS_SIZE]
