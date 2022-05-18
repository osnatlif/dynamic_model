# calculate emax
# return the number of iterations done during calculation
cpdef int calculate_emax(
	double[:,:,:,:,:,:,:,:,:,:] w_emax,
	double[:,:,:,:,:,:,:,:,:,:] h_emax,
	double[:,:,:,:,:,:] w_s_emax,
	double[:,:,:] h_s_emax,
	int adjust_bp, 
	int verbose)

cpdef double[:,:,:,:,:,:,:,:,:,:] create_married_emax()

cpdef double[:,:,:,:,:,:] create_single_w_emax()

cpdef double[:,:,:] create_single_h_emax()