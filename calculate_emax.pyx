import numpy as np
from single_men import single_men
from single_women import single_women
from married_couple cimport married_couple
cimport constant_parameters as c


cpdef double[:,:,:,:,:,:,:,:,:,:] create_married_emax():
    return np.ndarray(
        [c.T_MAX, c.EXP_SIZE, c.KIDS_SIZE, c.WORK_SIZE, c.ABILITY_SIZE, c.ABILITY_SIZE, c.SCHOOL_SIZE, c.SCHOOL_SIZE,
         c.MATCH_Q_SIZE, c.BP_SIZE])


cpdef double[:,:,:,:,:,:] create_single_w_emax():
    return np.ndarray([c.T_MAX, c.EXP_SIZE, c.KIDS_SIZE, c.WORK_SIZE, c.ABILITY_SIZE, c.SCHOOL_SIZE])


cpdef double[:,:,:] create_single_h_emax():
    return np.ndarray([c.T_MAX, c.ABILITY_SIZE, c.SCHOOL_SIZE])


cpdef int calculate_emax(
	double[:,:,:,:,:,:,:,:,:,:] w_emax,
	double[:,:,:,:,:,:,:,:,:,:] h_emax,
	double[:,:,:,:,:,:] w_s_emax,
	double[:,:,:] h_s_emax,
	int adjust_bp, 
	int verbose):
  cdef int iter_count = 0
  cdef int t
  cdef int s
  # running until the one before last period
  for t in range(c.T_MAX - 2, 0, -1):
    # EMAX FOR SINGLE MEN
    for s in range(0, c.SCHOOL_SIZE):          # SCHOOL_H_VALUES
      iter_count += single_men(s, t, w_emax, h_emax, w_s_emax, h_s_emax, adjust_bp, verbose)
    # EMAX FOR SINGLE WOMEN
    for s in range(1, c.SCHOOL_SIZE):          # SCHOOL_W_VALUES
      iter_count += single_women(s, t, w_emax, h_emax, w_s_emax, h_s_emax, adjust_bp, verbose)
    # EMAX FOR MARRIED COUPLE
    for s in range(1, c.SCHOOL_SIZE):          # SCHOOL_W_VALUES
      iter_count += married_couple(s, t, w_emax, h_emax, w_s_emax, h_s_emax, adjust_bp, verbose)

  return iter_count
