import numpy as np
import parameters as p
import constant_parameters as c
from random_pool import draw_3
from random_pool import draw_p
from draw_husband import first
wives = np.loadtxt("wives.out")


class Wife:
  def __init__(self):
    # following are indicators for the wife's schooling they have values of 0/1 and only one of them could be 1
    self.HSD = 0   # should always remain 0
    self.HSG = 0
    self.SC = 0
    self.CG = 0
    self.PC = 0
    self.WS = 0    # wife schooling, can get values of 1-4 (value of 0 is not possible)
    self.WE = 0    # wife experience
    self.emp_state = c.UNEMP
    self.ability_w_value = 0
    self.ability_wi = 0
    self.Q = 0.0
    self.Q_INDEX = 0
    self.similar_educ = 0.0
    self.AGE = 0
    self.age_index = 0
    self.T_END = 0


def update_wife_schooling(t, wife):
  # T_END is used together with the t index which get values 0-26
  wife.AGE = c.AGE_VALUES[wife.WS] + t
  wife.age_index = c.AGE_INDEX_VALUES[wife.WS]
  wife.T_END = c.TERMINAL - c.AGE_VALUES[wife.WS] - 1
  if wife.WS == 1:
    wife.HSG = 1
    wife.SC = 0
    wife.CG = 0
    wife.PC = 0
  elif wife.WS == 2:
    wife.SC = 1
    wife.HSG = 0
    wife.CG = 0
    wife.PC = 0
  elif wife.WS == 3:
    wife.CG = 1
    wife.HSG = 0
    wife.SC = 0
    wife.PC = 0
  elif wife.WS == 4:
    wife.PC = 1
    wife.HSG = 0
    wife.SC = 0
    wife.CG = 0
  else:
    assert False

  if t > wife.T_END:
    return False
  return True


def draw_wife(t, age_index, HS):
  result = Wife()
  result.Q_INDEX = draw_3()
  result.Q = c.normal_arr[result.Q_INDEX]*p.sigma4
  result.ability_wi = draw_3()
  result.ability_w_value = c.normal_arr[result.ability_wi] * p.sigma3
  wives_arr = wives[t+age_index]
  prob = draw_p()

  # find the first index in the wife array that is not less than the probability
  # note: first column of the wife matrix is skipped since it is just an index, hence the: "+1"
  value, w_index = first(wives_arr[2:], condition=lambda x: x >= prob)
  assert(w_index < 40)   # index will be in the range: 0-39
  result.WS = int(w_index/10) + 1
  assert result.WS in range(1, 5)  # wife schooling is in the range: 1-4

  result.WE = c.exp_vector[w_index % 5]        # [0,4]->0, [5,9]->1, [10,14]->0, [15-19]->1, etc.
  result.emp_state = int(w_index/5) % 2
  assert(result.emp_state == c.EMP or result.emp_state == c.UNEMP)

  if result.WS == HS:
    if HS == 2:
      result.similar_educ = p.EDUC_MATCH_2
    elif HS == 3:
      result.similar_educ = p.EDUC_MATCH_3
    elif HS == 4:
      result.similar_educ = p.EDUC_MATCH_4
    elif HS == 5:
      result.similar_educ = p.EDUC_MATCH_5
  return result


def print_wife(wife):
  print("Wife")
  print("Schooling: ", wife.WS)
  print("Schooling Map: ", wife.HSD, " ", wife.HSG, " ", wife.SC, " ", wife.CG, " ", wife.PC)
  print("Experience: ", wife.WE)
  print("Ability: (", wife.ability_wi,  ", ", wife.ability_w_value, ")")
  print("Match Quality: (", wife.Q_INDEX, ", ", wife.Q, ")")
  print("Age: ", wife.AGE)
  print("Last Period: ", wife.T_END)