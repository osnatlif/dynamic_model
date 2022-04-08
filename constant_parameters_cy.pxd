# number of draws backward
cdef int DRAW_B
cdef int DRAW_F

cdef int NO_KIDS
cdef double UNEMP_WOMEN_RATIO
cdef double beta0

# use this instead of: std::numeric_limits<>::lowest()
# so it is more clear when the number is printed
cdef double MINIMUM_UTILITY
cdef double* cs_vector
cdef int CS_SIZE
cdef int UTILITY_SIZE
cdef double* bp_vector

# experience - 5 point grid
cdef int* EXP_VALUES
cdef int EXP_SIZE
cdef int* exp_vector

# number of children: (0, 1, 2, 3+)
cdef int* KIDS_VALUES
cdef int KIDS_SIZE

# work status: (unemp, emp)
cdef int UNEMP
cdef int EMP
cdef int* WORK_VALUES
cdef int WORK_SIZE

# ability wife/husband: (low, medium, high))
cdef int* ABILITY_VALUES
cdef int ABILITY_SIZE
cdef double* normal_arr

# marital status: (unmarried, married)
cdef int UNMARRIED
cdef int MARRIED
cdef int* MARITAL_VALUES

# school groups
cdef int* SCHOOL_H_VALUES
cdef int* SCHOOL_W_VALUES
cdef int SCHOOL_SIZE

# match quality: (high, medium, low)
cdef int* MATCH_Q_VALUES
cdef int MATCH_Q_SIZE

# wife bargaining power
cdef double INITIAL_BP
cdef double NO_BP
cdef double* BP_W_VALUES
cdef int BP_SIZE

# maximum age
cdef int TERMINAL
# 28 periods, 45years - 18years
cdef int T_MAX
cdef int* AGE_INDEX_VALUES
cdef int* AGE_VALUES

# maximum fertility age
cdef int MAX_FERTILITY_AGE
