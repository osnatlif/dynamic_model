cimport draw_wife

# Husband class
cdef class Husband:
  cdef int H_HSD
  cdef int H_HSG
  cdef int H_SC
  cdef int H_CG
  cdef int H_PC
  cdef int HS
  cdef int HE
  cdef double ability_h_value
  cdef int ability_hi
  cdef int AGE
  cdef int age_index
  cdef int T_END

# update school and age of husband
# return indication (0,1) on whether calculation should stop or continue
cdef int update_school_and_age(int school_group, int t, Husband husband)

# draw a husband
cdef Husband draw_husband(int t, draw_wife.Wife wife, int forward)
