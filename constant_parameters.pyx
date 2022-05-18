# number of draws
cdef int DRAW_B = 1
cdef int DRAW_F = 5000

cdef int NO_KIDS = 0
cdef double UNEMP_WOMEN_RATIO = 0.45
cdef double beta0 = 0.983  # discount rate

cdef double MINIMUM_UTILITY = float('-inf')
cdef int CS_SIZE = 11
cdef double[11] cs_vector = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
cdef int UTILITY_SIZE = CS_SIZE*2
cdef double[11] bp_vector = cs_vector

# experience - 5 point grid
cdef int EXP_SIZE = 5
cdef int[5] EXP_VALUES = [0, 1, 2, 3, 4]
cdef int[5] exp_vector = [0, 2, 4, 8, 16]

# number of children: (0, 1, 2, 3+)
cdef int KIDS_SIZE = 4
cdef int[4] KIDS_VALUES = [0, 1, 2, 3]
cdef MAX_NUM_KIDS = KIDS_SIZE - 1

# work status: (unemp, emp)
cdef int UNEMP = 0
cdef int EMP = 1
cdef int WORK_SIZE = 2
cdef int[2] WORK_VALUES = [UNEMP, EMP]

# ability wife/husband: (low, medium, high))
cdef int ABILITY_SIZE = 3
cdef int[3] ABILITY_VALUES = [1, 2, 3]
cdef double[3] normal_arr = [-1.150, 0.0, 1.150]

# marital status: (unmarried, married)
cdef int UNMARRIED = 0
cdef int MARRIED = 1
cdef int[2] MARITAL_VALUES = [1, 2]

# school groups
cdef int SCHOOL_SIZE = 5
cdef int W_SCHOOL_SIZE = 4
cdef int[5] SCHOOL_H_VALUES = [0, 1, 2, 3, 4]
cdef int[4] SCHOOL_W_VALUES = [1, 2, 3, 4] # women do not have the HSD school group
SCHOOL_NAMES = ["HSD", "HSG", "SC", "CG", "PC"]

# match quality: (high, medium, low)
cdef int MATCH_Q_SIZE = 3
cdef int[3] MATCH_Q_VALUES = [0, 1, 2]

# wife bargaining power
cdef double INITIAL_BP = 0.5
cdef double NO_BP = -99.0
cdef int BP_SIZE = 9
cdef double[9] BP_W_VALUES = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8]

# maximum age
cdef int TERMINAL = 45
# 28 periods, 45years - 18years
cdef int T_MAX = 28
cdef int[5] AGE_INDEX_VALUES = [0, 0, 2, 4, 7]
cdef int[5] AGE_VALUES = [18, 18, 20, 22, 25]

# maximum fertility age
cdef int MAX_FERTILITY_AGE = 40
