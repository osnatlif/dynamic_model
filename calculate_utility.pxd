from draw_husband cimport Husband
from draw_wife cimport Wife

# Utility class
cdef class Utility:
  cdef double[:] wife
  cdef double[:] husband
  cdef double[:] wife_s
  cdef double husband_s

  cdef reset(self)

# calculate_utility function
# return Utility class
cdef Utility calculate_utility(
        double[:,:,:,:,:,:,:,:,:,:] w_emax,
        double[:,:,:,:,:,:,:,:,:,:] h_emax,
        double[:,:,:,:,:,:] w_s_emax,
        double[:,:,:] h_s_emax,
        int kids,
        double wage_h,
        double wage_w,
        int choose_partner,
        int M,
        Wife wife,
        Husband husband,
        int t,
        double BP,
        int single_men)
