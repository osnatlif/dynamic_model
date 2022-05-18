import numpy as np
cimport parameters as p
cimport constant_parameters as c
cimport draw_husband
cimport draw_wife
from calculate_wage cimport calculate_wage_h, calculate_wage_w
from calculate_utility cimport calculate_utility, Utility
from marriage_emp_decision cimport marriage_emp_decision, MarriageEmpDecision

cdef married_couple(
		int WS,
		int t,
		double[:,:,:,:,:,:,:,:,:,:] w_emax,
		double[:,:,:,:,:,:,:,:,:,:] h_emax,
		double[:,:,:,:,:,:] w_s_emax,
		double[:,:,:] h_s_emax,
		int adjust_bp,
		int verbose):
	if verbose:
		print("====================== married couple: ", WS, ", ", t, " ======================")
	cdef draw_wife.Wife base_wife = draw_wife.Wife()
	cdef draw_husband.Husband base_husband = draw_husband.Husband()
	if draw_wife.update_wife_schooling(WS, t, base_wife) == 0:  # update her schooling according to her school_group
		return 0
	cdef int iter_count = 0
	cdef int w_exp_i
	cdef int ability_wi
	cdef int ability_hi
	cdef int kids
	cdef int prev_emp_state
	cdef int HS
	cdef int Q_INDEX
	cdef int pbi
	cdef int draw_b
	cdef double w_sum
	cdef double h_sum
	cdef MarriageEmpDecision decision

	cdef Utility utility = Utility()
	for w_exp_i in range(0, c.EXP_SIZE):  # for each experience level: 5 levels - open loop of experience
		base_wife.WE = c.exp_vector[w_exp_i]
		for ability_wi in range(0, c.ABILITY_SIZE):  # for each ability level: low, medium, high - open loop of ability
			base_wife.ability_wi = ability_wi
			base_wife.ability_w_value = c.normal_arr[ability_wi] * p.sigma3  # wife ability - low, medium, high
			for ability_hi in range(0, c.ABILITY_SIZE):  # for each ability level: low, medium, high - open loop of ability
				base_husband.ability_hi = ability_hi
				base_husband.ability_h_value = c.normal_arr[ability_hi] * p.sigma3  # wife ability - low, medium, high
				for kids in range(0, c.KIDS_SIZE):  # for each number of kids: 0, 1, 2,  - open loop of kids
					for prev_emp_state in range(0, c.WORK_SIZE):  # two options: employed and unemployed
						base_wife.emp_state = prev_emp_state
						for HS in range (0, 5):    # 5 levels of schooling for husbands
							if draw_husband.update_school_and_age(HS, t, base_husband) == False:
								if verbose:
									print("skipping husband")
									print(base_husband)
									print( "================" )
								continue
							if HS == WS:
								base_wife.similar_educ = p.EDUC_MATCH[WS]
							for Q_INDEX in range(0, c.MATCH_Q_SIZE):        # MATCH_Q_VALUES: 0,1,2
								base_wife.Q = c.normal_arr[Q_INDEX]*p.sigma4
								base_wife.Q_INDEX = Q_INDEX
								for bpi in range(0, c.BP_SIZE):
									bp = c.BP_W_VALUES[bpi]
									w_sum = 0.0
									h_sum = 0.0
									for draw_b in range(0, c.DRAW_B):
										utility.reset()
										wife = base_wife
										husband = base_husband
										wage_h = calculate_wage_h(husband, np.random.normal(0, 1))
										wage_w = calculate_wage_w(wife, np.random.uniform(0, 1), np.random.normal(0, 1))
										CHOOSE_PARTNER = 1
										single_men = False
										utility = calculate_utility(w_emax, h_emax, w_s_emax, h_s_emax, kids, wage_h, wage_w,
																										CHOOSE_PARTNER, c.MARRIED, wife, husband, t, bp, single_men)
										if verbose:
											print(wife)
											print(husband)
										# marriage decision - outside option value wife
										decision = marriage_emp_decision(utility, bp, wife, husband, adjust_bp)
										if decision.M == c.MARRIED:
											w_sum += utility.wife[decision.max_weighted_utility_index]
											h_sum += utility.husband[decision.max_weighted_utility_index]
											if verbose:
												print("still married")
										else:
											w_sum += decision.outside_option_w_v
											h_sum += utility.husband_s
											if verbose:
												print("got divorced")
									if verbose:
										print("====================== new draw ======================")  #end draw backward loop
									w_emax[t][w_exp_i][kids][prev_emp_state][ability_wi][ability_hi][HS][WS][Q_INDEX][bpi] = w_sum/c.DRAW_B
									h_emax[t][w_exp_i][kids][prev_emp_state][ability_wi][ability_hi][HS][WS][Q_INDEX][bpi] = h_sum/c.DRAW_B
									if verbose:
										print("emax() = ", w_sum/c.DRAW_B, ", ", h_sum/c.DRAW_B)
										print("======================================================")
									iter_count = iter_count + 1

	return iter_count


