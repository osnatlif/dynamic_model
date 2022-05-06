# calculate emax
# return the number of iterations done during calculation
cdef int calculate_emax(
	double[:,:,:,:,:,:,:,:,:,:] w_emax,
	double[:,:,:,:,:,:,:,:,:,:] h_emax,
	double[:,:,:,:,:,:] w_s_emax,
	double[:,:,:] h_s_emax,
	int adjust_bp, 
	int verbose)
