# NetIncome class
cdef class NetIncome:
  cdef double net_income_s_h
  cdef double net_income_s_w
  cdef double net_income_m
  cdef double net_income_m_unemp

# calculate net income based on gross income
cdef NetIncome gross_to_net(int kids, double wage_w, double wage_h, int t, int age_index)
