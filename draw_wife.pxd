# Wife class
cdef class Wife:
    cdef int HSD
    cdef int HSG
    cdef int SC
    cdef int CG
    cdef int PC
    cdef int WS
    cdef int WE
    cdef int emp_state
    cdef double ability_w_value
    cdef int ability_wi
    cdef double Q
    cdef int Q_INDEX
    cdef double similar_educ
    cdef int AGE
    cdef int age_index
    cdef int T_END

# update school and age of wife
# return indication (0,1) on whether calculation should stop or continue
cdef int update_wife_schooling(int school_group, int t, Wife wife)

# draw a husband
cdef Wife draw_wife(int t, int age_index, int HS)

