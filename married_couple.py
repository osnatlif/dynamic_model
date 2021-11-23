import math
from random_pool import epsilon
from random_pool import draw_p
import parameters as p
import constant_parameters as c
import draw_husband
import draw_wife
import calculate_wage
import calculate_utility
import nash
import marriage_emp_decision

def married_couple(WS, t, w_emax, h_emax, w_s_emax, h_s_emax, adjust_bp, verbose):
	if verbose:
		print("====================== married couple: ", WS, ", ", t, " ======================")
	base_wife = draw_wife.Wife()
	base_husband = draw_husband.Husband()
	draw_wife.update_wife_schooling(t, base_wife)  # update her schooling according to her school_group
	iter_count = 0
	for w_exp_i in range(0, c.EXP_SIZE):  # for each experience level: 5 levels - open loop of experience
		base_wife.WE = c.exp_vector[w_exp_i]
		for ability_wi in range(1, 4):  # for each ability level: low, medium, high - open loop of ability
			base_wife.ability_hi = ability_wi
			base_wife.ability_h_value = c.normal_arr[ability_wi] * p.sigma3  # wife ability - low, medium, high
			for ability_hi in range(1, 4):  # for each ability level: low, medium, high - open loop of ability
				base_husband.ability_hi = ability_hi
				base_husband.ability_h_value = c.normal_arr[ability_hi] * p.sigma3  # wife ability - low, medium, high
				for kids in range(0, 4):  # for each number of kids: 0, 1, 2,  - open loop of kids
					for prev_emp_state in range(0, 2):  # two options: employed and unemployed
						base_wife.emp_state = prev_emp_state
						for HS in range (0,5):    # 5 levels of schooling for husbands
							draw_husband.update_school_and_age(HS, t, base_husband)  # update his schooling according to his school_group
							if update_school_and_age(HS, t, base_husband) == False:
								if verbose:
									print("skipping husband")
									print_husband(base_husband)
									print( "================" )
								continue
							if HS == WS:
								base_wife.similar_educ = p.EDUC_MATCH[WS]
							for Q_INDEX in range(0, 3):        # MATCH_Q_VALUES: 0,1,2
								base_wife.Q = normal_arr[Q_INDEX]*p.sigma_4
								base_wife.Q_INDEX = Q_INDEX
								for bpi in range(1, 10):
									bp = BP_W_LEN[bpi_index]
									w_sum = 0.0
									h_sum = 0.0
									for draw_b in range(0, DRAW_B):
										wife = base_wife
										husband = base_husband
										wage_h = calculate_wage_h(p, husband, epsilon())
										wage_w = calculate_wage_w(p, wife, draw_p(), epsilon())
										CHOOSE_PARTNER = 1
										single_men = False
										utility = calculate_utility.calculate_utility(w_emax, h_emax, w_s_emax, h_s_emax, kids, wage_h, wage_w,
																										CHOOSE_PARTNER, MARRIED, wife, husband, t, bp, single_men)
										if verbose:
											print_wife(wife)
											print_husband(husband)
										# marriage decision - outside option value wife
										decision = marriage_emp_decision(utility, bp, wife, husband, adjust_bp)
										if decision.M == MARRIED:
											w_sum += utility.U_W[decision.max_weighted_utility_index]
											h_sum += utility.U_H[decision.max_weighted_utility_index]
											if verbose:
												print("still married")
										else:
											w_sum += decision.outside_option_w_v
											h_sum += utility.U_H_S
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


