from draw_husband_cy cimport Husband_cy
from draw_wife_cy cimport Wife_cy

cdef double calculate_wage_h_cy(Husband_cy husband, double epsilon)

cdef double calculate_wage_w_cy(Wife_cy wife, double w_draw, double epsilon)
