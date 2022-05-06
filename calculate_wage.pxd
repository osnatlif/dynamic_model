from draw_husband cimport Husband
from draw_wife cimport Wife

# calculate wage for men
cdef double calculate_wage_h(Husband husband, double epsilon)

# calculate wage for women
cdef double calculate_wage_w(Wife wife, double w_draw, double epsilon)
