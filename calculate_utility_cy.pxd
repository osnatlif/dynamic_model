from draw_husband_cy cimport Husband_cy

# calculate_utility function
# return Utility class
cdef calculate_utility_cy(
        double[:,:,:,:,:,:,:,:,:,:] w_emax,
        double[:,:,:,:,:,:,:,:,:,:] h_emax,
        double[:,:,:,:,:,:] w_s_emax,
        double[:,:,:] h_s_emax,
        int kids,
        double wage_h,
        double wage_w,
        int choose_partner,
        int M, wife, Husband_cy husband,
        int t,
        double BP,
        int single_men)

# Utility class
cdef class Utility_cy:
  cdef double[:]  wife
  cdef double[:] husband
  cdef double[:] wife_s
  cdef double husband_s

  cdef reset(self)
