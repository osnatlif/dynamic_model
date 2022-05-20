cimport parameters as p
cimport constant_parameters as c
from draw_wife cimport Wife
import numpy as np

cdef double[:,:] husbands2 = np.loadtxt("husbands_2.out")
cdef double[:,:] husbands3 = np.loadtxt("husbands_3.out")
cdef double[:,:] husbands4 = np.loadtxt("husbands_4.out")
cdef double[:,:] husbands5 = np.loadtxt("husbands_5.out")

cdef class Husband:
  def __init__(self):
    self.H_HSD = 0
    self.H_HSG = 0
    self.H_SC = 0
    self.H_CG = 0
    self.H_PC = 0
    self.HS = 0   # husband schooling, can get values of 0-4
    self.HE = 0   # husband experience
    self.ability_h_value = 0.0
    self.ability_hi = 0
    self.AGE = 0
    self.age_index = 0
    self.T_END = 0

  def __str__(self):
    return "Husband\n\tSchooling: " + str(self.HS) + "\n\tSchooling Map: " + str(self.H_HSD)+","+str(self.H_HSG)+","+str(self.H_SC)+","+str(self.H_CG)+","+str(self.H_PC) + \
                                     "\n\tExperience: " + str(self.HE) + "\n\tAbility: " + str(self.ability_hi)+","+str(self.ability_h_value) + \
                                     "\n\tAge: " + str(self.AGE) + "\n\tAge Index: " + str(self.age_index) + "\n\tLast Period: " + str(self.T_END)


cpdef int update_school_and_age(int school_group, int t, Husband husband):   # used only for calculating the EMAX of single men - Backward
  husband.AGE = c.AGE_VALUES[school_group] + t
  husband.age_index = c.AGE_INDEX_VALUES[school_group]         # AGE_INDEX_VALUES = [0, 0, 2, 4, 7]
  husband.T_END = c.TERMINAL - c.AGE_VALUES[school_group] - 1  # AGE_VALUES = [18, 18, 20, 22, 25]
  if husband.AGE >= c.AGE_VALUES[husband.HS]:
    husband.HE = husband.AGE - c.AGE_VALUES[husband.HS]
  else:
    husband.HE = 0  # if husband is still at school, experience would be zero
  update_school(husband)
  if t > husband.T_END:
    return 0
  return 1


cpdef update_school_and_age_f(Wife wife, Husband husband):     # used only for forward solution - when wife draw a partner
  husband.AGE = wife.AGE
  husband.age_index = wife.age_index         # AGE_INDEX_VALUES = [0, 0, 2, 4, 7]
  husband.T_END = wife.T_END                    # AGE_VALUES = [18, 18, 20, 22, 25]
  if husband.AGE >= c.AGE_VALUES[husband.HS]:
    husband.HE = husband.AGE - c.AGE_VALUES[husband.HS]
  else:
    husband.HE = 0  # if husband is still at school, experience would be zero
  update_school(husband)


cpdef update_school(Husband husband):         # this function update education in Husnabds structures
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


cpdef Husband draw_husband(int t, Wife wife, int forward):
  cdef Husband result = Husband()
  result.ability_hi = np.random.randint(0, 2)                                           # draw ability index
  result.ability_h_value = c.normal_arr[result.ability_hi] * p.sigma3   # calculate ability value

  cdef double[:,:] tmp_husbands
  if wife.WS == 1:
    tmp_husbands = husbands2
  elif wife.WS == 2:
    tmp_husbands = husbands3
  elif wife.WS == 3:
    tmp_husbands = husbands4
  else:
    tmp_husbands = husbands5

  cdef double[:] husband_arr = tmp_husbands[t+wife.age_index]      # t+wife.age_index = wife's age which is identical to husband's age
  cdef double prob = np.random.uniform(0, 1)
  # find the first index in the husband array that is not less than the probability
  # note: first column of the husband matrix is skipped since it is just an index, hence the: [2:]
  cdef int h_index = 0
  cdef double value
  for value in husband_arr:
    if value >= prob:
      break
    h_index +=1
  # husband schooling is in the range: 0-4
  result.HS = int(h_index/5)
  assert(result.HS in range(0, 5))
  if forward:
    update_school_and_age_f(wife, result)
  else:
    update_school_and_age(result.HS, t, result)

  return result
