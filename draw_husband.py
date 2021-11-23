import parameters as p
import constant_parameters as c
from random_pool import draw_3
from random_pool import draw_p
import numpy as np

husbands2 = np.loadtxt("husbands_2.out")
husbands3 = np.loadtxt("husbands_3.out")
husbands4 = np.loadtxt("husbands_4.out")
husbands5 = np.loadtxt("husbands_5.out")


class Husband:
  def __init__(self):
    self.H_HSD = 0
    self.H_HSG = 0
    self.H_SC = 0
    self.H_CG = 0
    self.H_PC = 0
    self.HS = 0   # husband schooling, can get values of 0-4
    self.HE = 0    # husband experience
    self.ability_h_value = 0.0
    self.ability_hi = 0
    self.AGE = 0
    self.age_index = 0
    self.T_END = 0


def first(iterable, condition=lambda x: True):
  # Returns the first item in the `iterable` that satisfies the `condition`
  # If the condition is not given, returns the first item of the iterable
  # Raises `StopIteration` if no item satysfing the condition is found.
  return next(x for x in iterable if condition(x))


def update_school_and_age(school_group, t, husband):   # used only for calculating the EMAX of single men - Backward
  husband.AGE = c.AGE_VALUES[school_group] + t
  husband.age_index = c.AGE_INDEX_VALUES[school_group]         # AGE_INDEX_VALUES = [0, 0, 2, 4, 7]
  husband.T_END = c.TERMINAL - c.AGE_VALUES[school_group] - 1  # AGE_VALUES = [18, 18, 20, 22, 25]
  if husband.AGE >= c.AGE_VALUES[husband.HS]:
    husband.HE = husband.AGE - c.AGE_VALUES[husband.HS]
  else:
    husband.HE = 0  # if husband is still at school, experience would be zero
  update_school(husband)
  if t > husband.T_END:
    return False
  return True


def update_school_and_age_f(wife, husband):     # used only for forward solution - when wife draw a partner
  husband.AGE = wife.AGE
  husband.age_index = wife.age_index         # AGE_INDEX_VALUES = [0, 0, 2, 4, 7]
  husband.T_END = wife.T_END                    # AGE_VALUES = [18, 18, 20, 22, 25]
  if husband.AGE >= c.AGE_VALUES[husband.HS]:
    husband.HE = husband.AGE - c.AGE_VALUES[husband.HS]
  else:
    husband.HE = 0  # if husband is still at school, experience would be zero
  update_school(husband)


def update_school(husband):         # this function update education in Husnabds structures
  if husband.HS == 0:
    husband.H_HSD = 1
    husband.H_HSG = 0
    husband.H_SC = 0
    husband.H_CG = 0
    husband.H_PC = 0
  elif husband.HS == 1:
    husband.H_HSG = 1
    husband.H_HSD = 0
    husband.H_SC = 0
    husband.H_CG = 0
    husband.H_PC = 0
  elif husband.HS == 2:
    husband.H_SC = 1
    husband.H_HSG = 0
    husband.H_HSD = 0
    husband.H_CG = 0
    husband.H_PC = 0
  elif husband.HS == 3:
    husband.H_CG = 1
    husband.H_HSG = 0
    husband.H_HSD = 0
    husband.H_SC = 0
    husband.H_PC = 0
  elif husband.HS == 4:
    husband.H_PC = 1
    husband.H_HSG = 0
    husband.H_HSD = 0
    husband.H_SC = 0
    husband.H_CG = 0
  else:
    assert False


def draw_husband(t, wife):
  result = Husband()
  result.ability_hi = draw_3()                                            # draw ability index
  result.ability_h_value = c.normal_arr[result.ability_hi] * p.sigma3   # calculate ability value

  if wife.WS == 1:
    tmp_husbands = husbands2
  elif wife.WS == 2:
    tmp_husbands = husbands3
  elif wife.WS == 3:
    tmp_husbands = husbands4
  else:
    tmp_husbands = husbands5

  husband_arr = tmp_husbands[t+wife.age_index]      # t+wife.age_index = wife's age which is identical to husband's age
  prob = draw_p()
  # find the first index in the husband array that is not less than the probability
  # note: first column of the husband matrix is skipped since it is just an index, hence the: "+1"
  value = first(husband_arr[2:], condition=lambda x: x >= prob)
  h_index = husband_arr[2:].index(value)
  # husband schooling is in the range: 0-4
  result.HS = h_index/5
  assert(result.HS in range(1, 6))
  update_school_and_age(result, wife)
#  result.HE = h_index % 5 if husband experience is endogenious - you need to draw his experience here
  return result


def print_husband(husband):
  print("Husband")
  print("Schooling: ", husband.WS)
  print("Schooling Map: ", husband.HSD, " ", husband.HSG, " ", husband.SC, " ", husband.CG, " ", husband.PC)
  print("Experience: ", husband.WE)
  print("Ability: (", husband.ability_wi, ", ", husband.ability_w_value, ")")
  print("Match Quality: (", husband.Q_INDEX, ", ", husband.Q, ")")
  print("Age: ", husband.AGE)
  print("Last Period: ", husband.T_END)
