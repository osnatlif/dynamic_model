# number of draws backward
cdef int DRAW_B = 1   # DRAWS
cdef int DRAW_F = 5000

cdef int NO_KIDS = 0
cdef double UNEMP_WOMEN_RATIO = 0.45
cdef double beta0 = 0.983  # discount rate

# use this instead of: std::numeric_limits<>::lowest()
# so it is more clear when the number is printed
cdef double MINIMUM_UTILITY = float('-inf')
cdef double* cs_vector = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
cdef int CS_SIZE = 11
cdef int UTILITY_SIZE = CS_SIZE*2
cdef double* bp_vector = cs_vector

# experience - 5 point grid
cdef int* EXP_VALUES = [0, 1, 2, 3, 4]
cdef int EXP_SIZE = 5
cdef int* exp_vector = [0, 2, 4, 8, 16]

# number of children: (0, 1, 2, 3+)
cdef int* KIDS_VALUES = [0, 1, 2, 3]
cdef int KIDS_SIZE = 4

# work status: (unemp, emp)
cdef int UNEMP = 0
cdef int EMP = 1
cdef int* WORK_VALUES = [UNEMP, EMP]
cdef int WORK_SIZE = 2

# ability wife/husband: (low, medium, high))
cdef int* ABILITY_VALUES = [1, 2, 3]
cdef int ABILITY_SIZE = 3
cdef double* normal_arr = [-1.150, 0.0, 1.150]

# marital status: (unmarried, married)
cdef int UNMARRIED = 0
cdef int MARRIED = 1
cdef int* MARITAL_VALUES = [1, 2]

# school groups
cdef int* SCHOOL_H_VALUES = [0, 1, 2, 3, 4]
cdef int* SCHOOL_W_VALUES = [1, 2, 3, 4]      # women does not have the HSD school group
cdef int SCHOOL_SIZE = 5
SCHOOL_NAMES = ["HSD", "HSG", "SC", "CG", "PC"]

# match quality: (high, medium, low)
cdef int* MATCH_Q_VALUES = [0, 1, 2]
cdef int MATCH_Q_SIZE = 3

# wife bargaining power
cdef double INITIAL_BP = 0.5
cdef double NO_BP = -99.0
cdef double* BP_W_VALUES = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8]
cdef int BP_SIZE = 9

# maximum age
cdef int TERMINAL = 45
# 28 periods, 45years - 18years
cdef int T_MAX = 28
cdef int* AGE_INDEX_VALUES = [0, 0, 2, 4, 7]
cdef int* AGE_VALUES = [18, 18, 20, 22, 25]

# maximum fertility age
cdef int MAX_FERTILITY_AGE = 40
