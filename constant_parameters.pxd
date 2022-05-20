# number of draws
cdef int DRAW_B

cdef int NO_KIDS
cdef double beta0

cdef double MINIMUM_UTILITY
cdef double[11] cs_vector
cdef double[11] bp_vector
cdef int CS_SIZE

# experience - 5 point grid
cdef int[5] exp_vector
cdef int EXP_SIZE

# number of children: (0, 1, 2, 3+)
cdef int KIDS_SIZE

# work status: (unemp, emp)
cdef int UNEMP
cdef int EMP
cdef int WORK_SIZE

# ability wife/husband: (low, medium, high))
# match quality: (high, medium, low)
cdef double[3] normal_vector
cdef int ABILITY_SIZE
cdef int MATCH_Q_SIZE

# marital status: (unmarried, married)
cdef int UNMARRIED
cdef int MARRIED

# school groups
cdef int SCHOOL_SIZE
cdef int W_SCHOOL_SIZE
# women do not have the HSD school group

# wife bargaining power
cdef double INITIAL_BP
cdef double NO_BP
cdef double[9] BP_W_VALUES
cdef int BP_SIZE

# maximum age
cdef int TERMINAL
# 28 periods, 45years - 18years
cdef int T_MAX
cdef int[5] AGE_INDEX_VALUES
cdef int[5] AGE_VALUES

# maximum fertility age
cdef int MAX_FERTILITY_AGE
