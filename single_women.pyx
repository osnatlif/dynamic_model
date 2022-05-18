import math
import copy
import numpy as np
cimport parameters as p
cimport constant_parameters as c
cimport draw_husband
cimport draw_wife
cimport calculate_wage
cimport calculate_utility
cimport nash
cimport marriage_emp_decision


def single_women(school_group, t, w_m_emax, h_m_emax, w_s_emax, h_s_emax, adjust_bp, verbose):
    if verbose:
        print("====================== single women: ", school_group, t, " ======================")
    cdef draw_wife.Wife base_wife = draw_wife.Wife()  # create a wife structure (and draw ability, in backward we redefine the ability in the loop
    cdef draw_wife.Wife wife = draw_wife.Wife()
    if draw_wife.update_wife_schooling(school_group, t, base_wife) == False:  # update her schooling according to her school_group
        return 0
    iter_count = 0
    for w_exp_i in range(0, c.EXP_SIZE):   # for each experience level: 5 levels - open loop of experience
        base_wife.WE = c.exp_vector[w_exp_i]
        for ability_i in range(0, c.ABILITY_SIZE):  # for each ability level: low, medium, high - open loop of ability
            base_wife.ability_wi = ability_i
            base_wife.ability_w_value = c.normal_arr[ability_i] * p.sigma3  # wife ability - low, medium, high
            for kids in range(0, 4):      # for each number of kids: 0, 1, 2,  - open loop of kids
                for prev_emp_state in range(0, 2):       # two options: employed and unemployed
                    base_wife.emp_state = prev_emp_state
                    sum = 0
                    if verbose:
                        print(base_wife)
                    for draw in range(0, c.DRAW_B):
                        wife = copy.deepcopy(base_wife)
                        husband = draw_husband.Husband()
                        wage_w = calculate_wage.calculate_wage_w(wife, np.random.uniform(0, 1), np.random.normal(0, 1))
                        # probabilty of meeting a potential husband
                        p_husband = math.exp(p.p0_w+p.p1_w * (wife.AGE+t)+p.p2_w * (wife.AGE+t)**2) / (1.0+math.exp(p.p0_w+p.p1_w * (wife.AGE+t)+p.p2_w * pow(wife.AGE+t, 2)))
                        CHOOSE_HUSBAND = 0
                        wage_h = 0.0
                        if np.random.uniform(0, 1) < p_husband:
                            CHOOSE_HUSBAND = 1
                            husband = draw_husband.draw_husband(t, wife, False)
                            wage_h = calculate_wage.calculate_wage_h(husband, np.random.normal(0, 1))

                        bp = c.INITIAL_BP
                        is_single_men = False
                        utility = calculate_utility.calculate_utility(w_m_emax, h_m_emax, w_s_emax, h_s_emax, kids, wage_h, wage_w, CHOOSE_HUSBAND, c.UNMARRIED, wife, husband, t, bp, is_single_men)
                        if CHOOSE_HUSBAND == 1:
                            bp = nash.nash(utility)  # Nash bargaining at first period of marriage
                        else:
                            bp = c.NO_BP
                        if verbose and CHOOSE_HUSBAND:
                            print(wife)
                        if bp != c.NO_BP:
                            # marriage decision
                            decision = marriage_emp_decision.marriage_emp_decision(utility, bp, wife, husband, adjust_bp)
                            if decision.M == c.MARRIED:
                                sum += utility.wife[decision.max_weighted_utility_index]
                                if verbose:
                                    print("got married")
                            else:
                                sum += decision.outside_option_w_v
                                if verbose:
                                    print("did not get married")
                        else:
                            sum += max(utility.wife_s[c.UNEMP], utility.wife_s[c.EMP])
                            if verbose:
                                print("did not get marriage offer")
                        if verbose:
                            print("====================== new draw ======================")
                    # end draw backward loop
                    w_s_emax[t][w_exp_i][kids][prev_emp_state][ability_i][school_group] = sum / c.DRAW_B
                    if verbose:
                       print("emax(", t, ", ", ability_i, ", ", school_group, ")=", sum / c.DRAW_B)
                       print("======================================================")
                    iter_count = iter_count + 1
    return iter_count
