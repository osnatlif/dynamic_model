from calculate_utility cimport Utility
from draw_husband cimport Husband
from draw_wife cimport Wife

cpdef int wife_emp_decision(Utility utility)

cpdef tuple marriage_emp_decision(Utility utility, double bp, Wife wife, Husband husband, int adjust_bp)
