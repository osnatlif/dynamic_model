# number of draws backward
cdef const int DRAW_B = 1   # DRAWS
cdef const int DRAW_F = 5000

cdef const int NO_KIDS = 0
cdef const double UNEMP_WOMEN_RATIO = 0.45
cdef const double beta0 = 0.983  # discount rate

# use this instead of: std::numeric_limits<>::lowest()
# so it is more clear when the number is printed
cdef const double MINIMUM_UTILITY = float('-inf')
cdef const int CS_SIZE = 11
cdef const double[11] cs_vector = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
cdef const int UTILITY_SIZE = CS_SIZE*2
cdef const double[11] bp_vector = cs_vector

# experience - 5 point grid
cdef const int EXP_SIZE = 5
cdef const int[5] EXP_VALUES = [0, 1, 2, 3, 4]
cdef const int[5] exp_vector = [0, 2, 4, 8, 16]

# number of children: (0, 1, 2, 3+)
cdef const int KIDS_SIZE = 4
cdef const int[4] KIDS_VALUES = [0, 1, 2, 3]

# work status: (unemp, emp)
cdef const int UNEMP = 0
cdef const int EMP = 1
cdef const int WORK_SIZE = 2
cdef const int[2] WORK_VALUES = [UNEMP, EMP]

# ability wife/husband: (low, medium, high))
cdef const int ABILITY_SIZE = 3
cdef const int[3] ABILITY_VALUES = [1, 2, 3]
cdef const double[3] normal_arr = [-1.150, 0.0, 1.150]

# marital status: (unmarried, married)
cdef const int UNMARRIED = 0
cdef const int MARRIED = 1
cdef const int[2] MARITAL_VALUES = [1, 2]

# school groups
cdef const int SCHOOL_SIZE = 5
cdef const int[5] SCHOOL_H_VALUES = [0, 1, 2, 3, 4]
cdef const int[4] SCHOOL_W_VALUES = [1, 2, 3, 4] # women does not have the HSD school group
SCHOOL_NAMES = ["HSD", "HSG", "SC", "CG", "PC"]

# match quality: (high, medium, low)
cdef const int MATCH_Q_SIZE = 3
cdef const int[3] MATCH_Q_VALUES = [0, 1, 2]

# wife bargaining power
cdef const double INITIAL_BP = 0.5
cdef const double NO_BP = -99.0
cdef const int BP_SIZE = 9
cdef const double[9] BP_W_VALUES = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8]

# maximum age
cdef const int TERMINAL = 45
# 28 periods, 45years - 18years
cdef const int T_MAX = 28
cdef const int[5] AGE_INDEX_VALUES = [0, 0, 2, 4, 7]
cdef const int[5] AGE_VALUES = [18, 18, 20, 22, 25]

# maximum fertility age
cdef const int MAX_FERTILITY_AGE = 40
