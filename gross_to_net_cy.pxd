
cdef class NetIncome_cy:
  cdef double net_income_s_h
  cdef double net_income_s_w
  cdef double net_income_m
  cdef double net_income_m_unemp

cdef NetIncome_cy gross_to_net_cy(int kids, double wage_w, double wage_h, int t, int age_index)
