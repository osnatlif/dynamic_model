# number of draws
cdef int DRAW_B
cdef int DRAW_F

cdef int NO_KIDS
cdef double UNEMP_WOMEN_RATIO
cdef double beta0

cdef double MINIMUM_UTILITY
cdef int CS_SIZE
cdef double[11] cs_vector
cdef int UTILITY_SIZE
cdef double[11] bp_vector

# experience - 5 point grid
cdef int EXP_SIZE
cdef int[5] EXP_VALUES
cdef int[5] exp_vector

# number of children: (0, 1, 2, 3+)
cdef int KIDS_SIZE
cdef int[4] KIDS_VALUES
cdef MAX_NUM_KIDS

# work status: (unemp, emp)
cdef int UNEMP
cdef int EMP
cdef int WORK_SIZE
cdef int[2] WORK_VALUES

# ability wife/husband: (low, medium, high))
cdef int ABILITY_SIZE
cdef int[3] ABILITY_VALUES
cdef double[3] normal_arr

# marital status: (unmarried, married)
cdef int UNMARRIED
cdef int MARRIED
cdef int[2] MARITAL_VALUES

# school groups
cdef int SCHOOL_SIZE
cdef int W_SCHOOL_SIZE
cdef int[5] SCHOOL_H_VALUES
cdef int[4] SCHOOL_W_VALUES

# match quality: (high, medium, low)
cdef int MATCH_Q_SIZE
cdef int[3] MATCH_Q_VALUES

# wife bargaining power
cdef double INITIAL_BP
cdef double NO_BP
cdef int BP_SIZE
cdef double[9] BP_W_VALUES

# maximum age
cdef int TERMINAL
# 28 periods, 45years - 18years
cdef int T_MAX
cdef int[5] AGE_INDEX_VALUES
cdef int[5] AGE_VALUES

# maximum fertility age
cdef int MAX_FERTILITY_AGE
