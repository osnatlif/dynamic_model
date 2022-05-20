from calculate_utility cimport Utility
from draw_husband cimport Husband
from draw_wife cimport Wife

cdef class MarriageEmpDecision:
  cdef int M
  cdef int max_weighted_utility_index
  cdef double outside_option_w_v
  cdef double outside_option_h_v
  cdef double outside_option_w

cpdef int wife_emp_decision(Utility utility)

cpdef MarriageEmpDecision marriage_emp_decision(Utility utility, double bp, Wife wife, Husband husband, int adjust_bp)
