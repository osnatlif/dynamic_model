cimport draw_wife_cy

cdef class Husband_cy:
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

cdef int update_school_and_age_cy(int school_group, int t, Husband_cy husband)
cdef update_school_cy(Husband_cy husband)
cdef Husband_cy draw_husband_cy(int t, draw_wife_cy.Wife_cy wife, int forward)