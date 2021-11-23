import constant_parameters as c
import numpy as np


# find the BP value that has the maximum nash value
def nash(utility):
  # return 0.5    -    if you want a constant bp of 0.5 - remove comment
  # marriage decision - outside option value wife
  outside_option_w_v = max(utility.U_W_S[0], utility.U_W_S[1])
  outside_option_h_v = utility.U_H_S
  temp = np.ones(c.CS_SIZE*2)
  nash_value = temp * c.MINIMUM_UTILITY   # initiate the array with -inf
  # leave only positive surplus for both
  for i in range(0, c.UTILITY_SIZE):
    if utility.U_W[i] > outside_option_w_v and utility.U_H[i] > outside_option_h_v:
      # if positive surplus for both
      nash_value[i] = (utility.U_W[i]-outside_option_w_v)**0.5 * (utility.U_H[i]-outside_option_h_v)**0.5

  max_nash_value = max(nash_value)
  max_nash_value_index = nash_value.index(max_nash_value)
  if max_nash_value == c.MINIMUM_UTILITY:
    return c.NO_BP

  return c.bp_vector[max_nash_value_index % c.CS_SIZE]
