import numpy as np
cimport parameters as p
cimport constant_parameters as c


cdef double[:,:] wives = np.loadtxt("wives.out")


cdef class Wife:
  def set_emp_state(self, state):
    self.emp_state = state

  def set_Q(self, Q_INDEX):
    self.Q_INDEX = Q_INDEX
    self.Q = c.normal_vector[Q_INDEX] * p.sigma4

  def increase_AGE(self):
    self.AGE += 1
  def get_AGE(self):
    return self.AGE

  def increase_Q(self):
    self.Q_INDEX += 1
    self.Q = c.normal_vector[self.Q_INDEX] * p.sigma4

  def decrease_Q(self):
    self.Q_INDEX -= 1
    self.Q = c.normal_vector[self.Q_INDEX] * p.sigma4

  def set_Q_index(self, Q_INDEX):
    self.Q_INDEX = Q_INDEX

  def get_Q(self):
    return self.Q

  def get_Q_INDEX(self):
    return self.Q_INDEX

  def get_emp_state(self):
    return self.emp_state

  def get_T_END(self):
    return self.T_END

  def get_AGE(self):
    return self.AGE
  def get_WE(self):
    return self.WE

  def get_WS(self):
    return self.WS

  def get_age_index(self):
    return self.age_index

  def calculate_lambda(self, n_kids, HS, M):
    # FERTILITY EXOGENOUS PROCESS - check for another child + update age of children
    # probability of another child parameters:
    # c1 previous work state - wife
    # c2 age wife - HSG
    # c3 age square  wife - HSG
    # c4 age wife - SC
    # c5 age square  wife - SC
    # c6 age wife - CG
    # c7 age square  wife - CG
    # c8 age wife - PC
    # c9 age square  wife - PC
    # c10 number of children at household
    # c11 schooling - husband
    # c12 unmarried
    return (p.c1 * self.emp_state + p.c2 * self.HSG * self.AGE + p.c3 * self.HSG * pow(self.AGE, 2) + p.c4 * self.SC * self.AGE +
            p.c5 * self.SC * pow(self.AGE, 2) + p.c6 * self.CG * self.AGE + p.c7 * self.CG * pow(self.AGE, 2) +
            p.c8 * self.PC * self.AGE + p.c9 * self.PC * pow(self.AGE, 2) + p.c10 * n_kids + p.c11 * HS * M + p.c12 * M)

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


cpdef int update_wife_schooling(int school_group, int t, Wife wife):
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


cpdef update_ability(int ability, Wife wife):
  wife.ability_wi = ability
  wife.ability_w_value = c.normal_vector[ability]*p.sigma3


cpdef Wife draw_wife(int t, int age_index, int HS):
  cdef Wife result = Wife()
  result.Q_INDEX = np.random.randint(0, 2)
  result.Q = c.normal_vector[result.Q_INDEX]*p.sigma4
  result.ability_wi = np.random.randint(0, 2)
  result.ability_w_value = c.normal_vector[result.ability_wi] * p.sigma3
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
