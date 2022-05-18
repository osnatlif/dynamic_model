
# calculate emax for a married couple
cdef married_couple(
		int WS,
		int t,
		double[:,:,:,:,:,:,:,:,:,:] w_emax,
		double[:,:,:,:,:,:,:,:,:,:] h_emax,
		double[:,:,:,:,:,:] w_s_emax,
		double[:,:,:] h_s_emax,
		int adjust_bp,
		int verbose)
