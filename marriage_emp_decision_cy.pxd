from calculate_utility_cy cimport Utility_cy
from draw_husband_cy cimport Husband_cy

cdef wife_emp_decision_cy(Utility_cy utility)

cdef marriage_emp_decision_cy(Utility_cy utility, double bp, wife, Husband_cy husband, int adjust_bp)
