import constant_parameters as c
import numpy as np


# find the BP value that has the maximum nash value
def nash(utility):
  # return 0.5    -    if you want a constant bp of 0.5 - remove comment
  # marriage decision - outside option value wife
  outside_option_w_v = max(utility.wife_s[c.UNEMP], utility.wife_s[c.EMP])
  outside_option_h_v = utility.husband_s
  temp = np.ones(c.CS_SIZE*2)
  nash_value = temp * c.MINIMUM_UTILITY   # initiate the array with -inf
  # leave only positive surplus for both
  for i in range(0, c.UTILITY_SIZE):
    if utility.wife[i] > outside_option_w_v and utility.husband[i] > outside_option_h_v:
      # if positive surplus for both
      nash_value[i] = (utility.wife[i]-outside_option_w_v)**0.5 * (utility.husband[i]-outside_option_h_v)**0.5

  max_nash_value = max(nash_value)
  max_nash_value_index = np.ravel(np.where(max_nash_value == nash_value))

  if max_nash_value == c.MINIMUM_UTILITY:
    return c.NO_BP

  assert len(max_nash_value_index) > 0
  return c.bp_vector[max_nash_value_index[0] % c.CS_SIZE]
