# number of draws
DRAW_B = 1
DRAW_F = 5000

NO_KIDS = 0
UNEMP_WOMEN_RATIO = 0.45
beta0 = 0.983  # discount rate

MINIMUM_UTILITY = float('-inf')
CS_SIZE = 11
cs_vector = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
UTILITY_SIZE = CS_SIZE*2
bp_vector = cs_vector

# experience - 5 point grid
EXP_SIZE = 5
EXP_VALUES = [0, 1, 2, 3, 4]
exp_vector = [0, 2, 4, 8, 16]

# number of children: (0, 1, 2, 3+)
KIDS_SIZE = 4
KIDS_VALUES = [0, 1, 2, 3]
MAX_NUM_KIDS = KIDS_SIZE - 1

# work status: (unemp, emp)
UNEMP = 0
EMP = 1
WORK_SIZE = 2
WORK_VALUES = [UNEMP, EMP]

# ability wife/husband: (low, medium, high))
ABILITY_SIZE = 3
ABILITY_VALUES = [1, 2, 3]
normal_arr = [-1.150, 0.0, 1.150]

# marital status: (unmarried, married)
UNMARRIED = 0
MARRIED = 1
MARITAL_VALUES = [1, 2]

# school groups
SCHOOL_SIZE = 5
W_SCHOOL_SIZE = 4
SCHOOL_H_VALUES = [0, 1, 2, 3, 4]
SCHOOL_W_VALUES = [1, 2, 3, 4] # women do not have the HSD school group
SCHOOL_NAMES = ["HSD", "HSG", "SC", "CG", "PC"]

# match quality: (high, medium, low)
MATCH_Q_SIZE = 3
MATCH_Q_VALUES = [0, 1, 2]

# wife bargaining power
INITIAL_BP = 0.5
NO_BP = -99.0
BP_SIZE = 9
BP_W_VALUES = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8]

# maximum age
TERMINAL = 45
# 28 periods, 45years - 18years
T_MAX = 28
AGE_INDEX_VALUES = [0, 0, 2, 4, 7]
AGE_VALUES = [18, 18, 20, 22, 25]

# maximum fertility age
MAX_FERTILITY_AGE = 40
