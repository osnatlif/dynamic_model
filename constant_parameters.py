# number of draws backward
# allow to be set as a compilation flag, defaults to 100
DRAW_B = 30   # DRAWS
DRAW_F = 5000

NO_KIDS = 0
UNEMP_WOMEN_RATIO = 0.45
beta0 = 0.983  # discount rate

# use this instead of: std::numeric_limits<>::lowest()
# so it is more clear when the number is printed
MINIMUM_UTILITY = float('-inf')
CS_SIZE = 11
UTILITY_SIZE = CS_SIZE*2
cs_vector = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
bp_vector = cs_vector

# experience - 5 point grid
EXP_SIZE = 5
EXP_VALUES = [0, 1, 2, 3, 4]
exp_vector = [0, 2, 4, 8, 16]

# number of children: (0, 1, 2, 3+)
KIDS_VALUES = [0, 1, 2, 3]

# work status: (unemp, emp)
UNEMP = 0
EMP = 1
WORK_VALUES = [0, 1]

# ability wife/husband: (low, medium, high))
ABILITY_VALUES = [1, 2, 3]
normal_arr = [-1.150, 0.0, 1.150]

# marital status: (unmarried, married)
UNMARRIED = 0
MARRIED = 1
MARITAL_VALUES = [1, 2]

# school groups
SCHOOL_H_VALUES = [0, 1, 2, 3, 4]
SCHOOL_W_VALUES = [1, 2, 3, 4]      # women does not have the HSD school group
SCHOOL_NAMES = ["HSD", "HSG", "SC", "CG", "PC"]

# match quality: (high, medium, low)
MATCH_Q_VALUES = [0, 1, 2]

# wife bargaining power
INITIAL_BP = 0.5
NO_BP = -99.0
BP_W_VALUES = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8]

# maximum age
TERMINAL = 45
# 28 periods, 45years - 18years
T_MAX = 28
AGE_INDEX_VALUES = [0, 0, 2, 4, 7]
AGE_VALUES = [18, 18, 20, 22, 25]

# maximum fertility age
MAX_FERTILITY_AGE = 40
