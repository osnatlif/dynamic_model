import numpy as np
cimport parameters as p
cimport constant_parameters as c


cdef double[:,:] wives = np.loadtxt("wives.out")


cdef class Wife:
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

  def __str__(self):
    return "Wife\n\tSchooling: " + str(self.WS) + "\n\tSchooling Map: " + str(self.HSD) + "," + str(self.HSG) + "," + str(self.SC) + "," + str(self.CG) + "," + str(self.PC) + \
           "\n\tExperience: " + str(self.WE) + "\n\tAbility: " + str(self.ability_wi) + "," + str(self.ability_w_value) + \
           "\n\tMatch Quality: " + str(self.Q_INDEX) + ", " + str(self.Q) + \
           "\n\tAge: " + str(self.AGE) + "\n\tAge Index: " + str(self.age_index) + "\n\tLast Period: " + str(self.T_END)


cdef int update_wife_schooling(int school_group, int t, Wife wife):
  # T_END is used together with the t index which get values 0-26
  wife.WS = school_group
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
    return 0
  return 1


cdef update_ability(int ability, Wife wife):
  wife.ability_wi = ability
  wife.ability_w_value = c.normal_arr[ability]*p.sigma3


cdef Wife draw_wife(int t, int age_index, int HS):
  cdef Wife result = Wife()
  result.Q_INDEX = np.random.randint(0, 2)
  result.Q = c.normal_arr[result.Q_INDEX]*p.sigma4
  result.ability_wi = np.random.randint(0, 2)
  result.ability_w_value = c.normal_arr[result.ability_wi] * p.sigma3
  cdef double[:] wives_arr = wives[t+age_index]
  cdef double prob = np.random.uniform(0, 1)

  cdef int w_index = 0
  cdef double value
  for value in wives_arr:
    if value >= prob:
      break
    w_index +=1

  assert(w_index < 40)   # index will be in the range: 0-39
  result.WS = int(w_index/10) + 1
  assert result.WS in range(1, 5)  # wife schooling is in the range: 1-4

  result.WE = c.exp_vector[w_index % 5]        # [0,4]->0, [5,9]->1, [10,14]->0, [15-19]->1, etc.
  result.emp_state = int(w_index/5) % 2
  assert(result.emp_state == c.EMP or result.emp_state == c.UNEMP)

  if result.WS == HS:
    result.similar_educ = p.EDUC_MATCH[HS]

  return result
