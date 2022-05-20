# number of draws
cdef int DRAW_B = 1

cdef int NO_KIDS = 0
cdef double beta0 = 0.983  # discount rate

cdef double MINIMUM_UTILITY = float('-inf')
cdef double[11] cs_vector = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
cdef double[11] bp_vector = cs_vector
cdef int CS_SIZE = 11

# experience - 5 point grid
cdef int[5] exp_vector = [0, 2, 4, 8, 16]
cdef int EXP_SIZE = 5

# number of children: (0, 1, 2, 3+)
cdef int KIDS_SIZE = 4

# work status: (unemp, emp)
cdef int UNEMP = 0
cdef int EMP = 1
cdef int WORK_SIZE = 2

# ability wife/husband: (low, medium, high))
# match quality: (high, medium, low)
cdef double[3] normal_vector = [-1.150, 0.0, 1.150]
cdef int ABILITY_SIZE = 3
cdef int MATCH_Q_SIZE = 3

# marital status: (unmarried, married)
cdef int UNMARRIED = 0
cdef int MARRIED = 1

# school groups
cdef int SCHOOL_SIZE = 5
cdef int W_SCHOOL_SIZE = 4
# women do not have the HSD school group

# wife bargaining power
cdef double INITIAL_BP = 0.5
cdef double NO_BP = -99.0
cdef double[9] BP_W_VALUES = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8]
cdef int BP_SIZE = 9

# maximum age
cdef int TERMINAL = 45
# 28 periods, 45years - 18years
cdef int T_MAX = 28
cdef int[5] AGE_INDEX_VALUES = [0, 0, 2, 4, 7]
cdef int[5] AGE_VALUES = [18, 18, 20, 22, 25]

# maximum fertility age
cdef int MAX_FERTILITY_AGE = 40


# constant values for the forward simulation
DRAW_F = 5000
UNEMP_WOMEN_RATIO = 0.45
MAX_NUM_KIDS = KIDS_SIZE - 1

# following values are needed for the forward simulation
# since pure python code cannot access the cython constants
F_KIDS_SIZE = KIDS_SIZE
F_UNEMP = UNEMP
F_EMP = EMP
F_UNMARRIED = UNMARRIED
F_MARRIED = MARRIED
F_SCHOOL_SIZE = SCHOOL_SIZE
F_W_SCHOOL_SIZE = W_SCHOOL_SIZE
F_INITIAL_BP = INITIAL_BP
F_NO_BP = NO_BP
F_T_MAX = T_MAX
F_MAX_FERTILITY_AGE = MAX_FERTILITY_AGE
F_CS_SIZE = CS_SIZE
