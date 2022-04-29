from calculate_utility_cy cimport Utility_cy
from draw_husband_cy cimport Husband_cy
from draw_wife_cy cimport Wife_cy

cdef class MarriageEmpDecision_cy:
  cdef int M
  cdef int max_weighted_utility_index
  cdef double outside_option_w_v
  cdef double outside_option_h_v
  cdef double outside_option_w

cdef int wife_emp_decision_cy(Utility_cy utility)

cdef MarriageEmpDecision_cy marriage_emp_decision_cy(Utility_cy utility, double bp, Wife_cy wife, Husband_cy husband, int adjust_bp)
