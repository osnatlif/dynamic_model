cdef class Wife_cy:
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

cdef int update_wife_schooling_cy(int school_group, int t, Wife_cy wife)
cdef Wife_cy draw_wife_cy(int t, int age_index, int HS)
