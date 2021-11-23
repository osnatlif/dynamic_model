import numpy as np
import math
from statistics import NormalDist
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


def calculate_emax(w_m_emax, h_m_emax, w_s_emax, h_s_emax, adjust_bp, verbose): 
  iter_count = 0
  # running until the one before last period
  for t in range(c.T_MAX - 2, 0):
    # EMAX FOR SINGLE MEN
    for HS in range(0, 5):          # SCHOOL_H_VALUES
      iter_count += single_men(p, HS, t, w_m_emax, h_m_emax, w_s_emax, h_s_emax, adjust_bp, verbose)
    # EMAX FOR SINGLE WOMEN
    for WS in range(1, 5):          # SCHOOL_W_VALUES
      iter_count += single_women(p, WS, t, w_m_emax, h_m_emax, w_s_emax, h_s_emax, adjust_bp, verbose)
    # EMAX FOR MARRIED COUPLE
    for WS in range(1, 5):          # SCHOOL_W_VALUES
      iter_count += married_couple(p, WS, t, w_m_emax, h_m_emax, w_s_emax, h_s_emax, adjust_bp, verbose)
  return iter_count


def mean(val_matrix, count_matrix, t, school_group):
  count = count_matrix[t][school_group]
  if count == 0:
    return 0.0
  return val_matrix[t][school_group]/count


def mean(val_arr, count_arr, school_group):
  count = count_arr[school_group]
  if count == 0:
    return 0.0
  return val_arr[school_group]/count


def calculate_moments(m, w_m_emax, h_m_emax, w_s_emax, h_s_emax, adjust_bp, verbose):
#  EstimatedMoments estimated
#  boost::math::normal normal_dist
#  SchoolingMatrix emp_total = {{{0}}}    # employment
#  SchoolingMatrix count_emp_total{{{0}}}
#  SchoolingMatrix emp_m{{{0}}}           # employment married
#  SchoolingMatrix emp_um{{{0}}}          # employment unmarried
#  SchoolingMeanArray emp_m_up            # employment unmarried up
#  SchoolingMeanArray emp_m_down          # employment unmarried down
#  SchoolingMeanArray emp_m_eq            # employment unmarried equal
  M_KIDS_SIZE = 5 # no kids, 1 kids, 2 kids, 3 kids 4+kids
  UM_KIDS_SIZE = 2 # no kids, with kids
#  SchoolingMeanArray emp_m_kids[M_KIDS_SIZE]     # employment married no kids
#  SchoolingMeanArray emp_um_kids[UM_KIDS_SIZE]   # employment unmarried and no children
#  SchoolingMatrix divorce{{{0}}}
#  SchoolingArray just_found_job_m{0}         # transition matrix - unemployment to employment (married)
#  SchoolingArray just_got_fired_m{0}         # transition matrix - employment to unemployment (married)
#  SchoolingArray just_found_job_um{0}        # transition matrix - unemployment to employment (unmarried)
#  SchoolingArray just_got_fired_um{0}        # transition matrix - employment to unemployment (unmarried)
#  SchoolingArray just_found_job_mc{0}        # transition matrix - unemployment to employment (married+kids)
#  SchoolingArray just_got_fired_mc{0}        # transition matrix - employment to unemployment (married+kids)
#  SchoolingArray count_just_got_fired_m{0}
#  SchoolingArray count_just_found_job_m{0}
#  SchoolingArray count_just_got_fired_um{0}
#  SchoolingArray count_just_found_job_um{0}
#  SchoolingArray count_just_got_fired_mc{0}
#  SchoolingArray count_just_found_job_mc{0}
#  SchoolingMeanMatrix wages_m_h
  # married men wages - 0 until 20+27 years of exp - 36-47 will be ignore in moments  
#  SchoolingMeanMatrix wages_w        # women wages if employed
#  SchoolingMeanArray wages_m_w_up    # married up women wages if employed
#  SchoolingMeanArray wages_m_w_down  # married down women wages if employed
#  SchoolingMeanArray wages_m_w_eq    # married equal women wages if employed
#  SchoolingMeanArray wages_um_w      # unmarried women wages if employed
#  SchoolingMatrix married{{{0}}}     # fertility and marriage rate moments   % married yes/no
#  SchoolingArray just_married{{0}}   # for transition matrix from single to married
#  SchoolingArray just_divorced{{0}}  # for transition matrix from married to divorce
#  SchoolingMeanArray age_at_first_marriage # age at first marriage
#  SchoolingMeanMatrix newborn_um      # new born in period t - for probability and distribution
#  SchoolingMeanMatrix newborn_m       # new born in period t - for probability and distribution
#  SchoolingMeanMatrix newborn_all       # new born in period t - for probability and distribution
#  SchoolingMeanArray duration_of_first_marriage # duration of marriage if divorce or 45-age of marriage if still married at 45.
  # husband education by wife education
#  UMatrix<SCHOOL_LEN, SCHOOL_LEN> assortative_mating_hist{{{0}}}
#  SchoolingArray assortative_mating_count{0}
#  SchoolingArray count_just_married{{0}}
#  SchoolingArray count_just_divorced{{0}}
#  SchoolingMeanArray n_kids_arr    # # of children by school group

  # school_group 0 is only for calculating the emax if single men - not used here
  for school_group in range(1, 5):       # SCHOOL_W_VALUES
    for draw_f in range(0, c.DRAW_F):   # start the forward loop
      IGNORE_T = 0
      husband = draw_husband.Husband()  # declare husband structure
      wife = draw_wide.Wife()           # declare wife structure
      wife.ability_wi = draw_3()        # draw wife's ability
      wife.ability_w_value = c.normal_arr[result.ability_wi] * p.sigma3
      update_wife_schooling(school_group, IGNORE_T, wife)
      if draw_f > c.DRAW_F*c.UNEMP_WOMEN_RATIO:   #update previous employment status according to proportion in population
        wife.emp_state = 1
      else:
        wife.emp_state = 1
      # kid age array maximum number of kids = 4 -  0 - oldest kid ... 3 - youngest kid
      MAX_NUM_KIDS = KIDS_LEN - 1
      kid_age = np.zeros(MAX_NUM_KIDS)
      DIVORCE = 0
      n_kids = 0
      n_kids_m = 0
      n_kids_um = 0
      duration = 0
      Q_minus_1 = 0.0
      bp = INITIAL_BP
      update_ability(p, draw_3(), wife)
      decision = MarriageEmpDecision.MarriageEmpDecision()

      # following 2 indicators are used to count age at first marriage
      # and marriage duration only once per draw
      first_marriage = True
      first_divorce = True
      # make choices for all periods
      last_t = wife.T_END
      if verbose:
        print("=========")
        print("new women")
        print("=========")
      # FIXME: husband moments are calculated up to last_t and not T_MAX
      for t in range(0, last_t):
        if verbose:
          print("========= ", t, " =========")
        prev_emp_state_w = wife.emp_state
        prev_M = decision.M
        new_born = 0
        choose_husband = False
        # draw husband if not already married
        if decision.M == c.UNMARRIED:
          bp = c.INITIAL_BP
          duration = 0
          wife.Q = 0.0
          # probability of meeting a potential husband
          choose_hudband_p = (exp(p.p0_w+p.p1_w*(wife.AGE)+p.p2_w*pow(wife.AGE,2))/
            (1.0+exp(p.p0_w+p.p1_w*(wife.AGE)+p.p2_w*pow(wife.AGE,2))))
          if draw_p() < choose_hudband_p:
            choose_husband = True
            husband = draw_husband( t, wife)
            wife.Q_INDEX = draw_3()  # draw wife's
            wife.Q = c.normal_arr[result.Q_INDEX] * p.sigma4
            draw_husband.update_school_and_age_f(wife,husband)
            assert(husband.AGE == wife.AGE)
            if verbose:
              print("new potential husband")

        # potential or current husband wage
          if decision.M == c.MARRIED or choose_husband:
            wage_h = calculate_wage_h(p, husband, epsilon())
          else:
            wage_h = 0.0
          wage_w = calculate_wage_w(p, wife, draw_p(), epsilon())
          is_single_men = False
          if decision.M == UNMARRIED and choose_husband:          # not married, but has potential husband - calculate initial BP
            utility = calculate_utility(p, w_m_emax, h_m_emax, w_s_emax, h_s_emax, n_kids, wage_h, wage_w,
              True, decision.M, wife, husband, t, bp, is_single_men)
            # Nash bargaining at first period of marriage
            bp = nash.nash(utility)
          if bp != c.NO_BP:
            ++estimated.bp_initial_dist[bp*10]
          else:
            choose_husband = False

        if decision.M == c.MARRIED:
          if verbose:
            print("existing husband")
        utility = calculate_utility.Utility()
        if decision.M == MARRIED or choose_husband:
          # at this point the BP is 0.5 if there is no marriage offer
          # BP is calculated by nash above if offer given
          # and is from previous period if already married
          # utility is calculated again based on the new BP
          utility = calculate_utility.calculate_utility(p, w_m_emax, h_m_emax, w_s_emax, h_s_emax, n_kids, wage_h, wage_w,
              True, decision.M, wife, husband, t, bp, is_single_men)
          decision = marriage_emp_decision.marriage_emp_decision(utility, bp, wife, husband, adjust_bp)
        else:
          assert(wage_h == 0.0)
          utility = calculate_utility(p, w_m_emax, h_m_emax, w_s_emax, h_s_emax, n_kids, wage_h, wage_w,
              False, decision.M, wife, husband, t, bp, is_single_men)
          wife.emp_state = wife_emp_decision.wife_emp_decision(utility)
        assert(t+wife.age_index < T_MAX)
        emp_total[t+wife.age_index][school_group] += wife.emp_state
        if decision.M == c.MARRIED:
          emp_m[t+wife.age_index][school_group] += wife.emp_state
        if decision.M == c.UNMARRIED:
          emp_um[t+wife.age_index][school_group] += wife.emp_state
        ++count_emp_total[t+wife.age_index][school_group]
        if bp != c.NO_BP:
          ++estimated.bp_dist[bp*10]
        if decision.M == c.MARRIED:
          ++estimated.cs_dist[decision.max_weighted_utility_index]
        # FERTILITY EXOGENOUS PROCESS - check for another child + update age of children
        # probability of another child parameters:
        # c1 previous work state - wife
        # c2 age wife - HSG
        # c3 age square  wife - HSG
        # c4 age wife - SC
        # c5 age square  wife - SC
        # c6 age wife - CG
        # c7 age square  wife - CG
        # c8 age wife - PC
        # c9 age square  wife - PC
        # c10 number of children at household
        # c11 schooling - husband
        # c12 unmarried
        c_lamda = (p.c1*wife.emp_state + p.c2*wife.HSG*(wife.AGE) + p.c3*wife.HSG*pow(wife.AGE,2) +
          p.c4*wife.SC*(wife.AGE) + p.c5*wife.SC*pow(wife.AGE,2) + p.c6*wife.CG*(wife.AGE) + p.c7*wife.CG*pow(wife.AGE,2) +
          p.c8*wife.PC*(wife.AGE) + p.c9*wife.PC*pow(wife.AGE,2) + p.c10*n_kids + p.c11*husband.HS*decision.M + p.c12*decision.M)
        child_prob = NormalDist(mu=0, sigma=1).pdf(c_lamda)
        if draw_p() < child_prob and wife.AGE < MAX_FERTILITY_AGE:
          new_born = 1
          n_kids = math.min(n_kids+1, MAX_NUM_KIDS)
          if decision.M == c.MARRIED:
            n_kids_m = math.min(n_kids_m+1, MAX_NUM_KIDS)
          else:
            n_kids_um = math.min(n_kids_um+1, MAX_NUM_KIDS)
          # set the age for the youngest kid
          assert(n_kids>0)
          assert(n_kids<=MAX_NUM_KIDS)
          kid_age[n_kids-1] = 1
        elif n_kids > 0:
          # no new born, but kids at house, so update ages
          if kid_age[0] == 18:
            # oldest kids above 18 leaves the household
            for order in range(0, MAX_NUM_KIDS-1):
              kid_age[order] = kid_age[order+1]
            kid_age[MAX_NUM_KIDS-1] = 0
            n_kids = n_kids -1
            assert(n_kids>=0)
          for order in range(0, MAX_NUM_KIDS):
            if kid_age[order] > 0:
              ++kid_age[order]
        # update the match quality
        if decision.M == c.MARRIED:
          Q_minus_1 = wife.Q
          DIVORCE = 0
          ++duration
          match_quality_change_prob = draw_p()
          if match_quality_change_prob < p.MATCH_Q_DECREASE and wife.Q_INDEX > 0:
            --wife.Q_INDEX
            wife.Q = normal_arr[wife.Q_INDEX]*p.sigma_4
          elif (match_quality_change_prob > p.MATCH_Q_DECREASE and
              match_quality_change_prob < p.MATCH_Q_DECREASE + p.MATCH_Q_INCREASE and wife.Q_INDEX < 2):
            ++wife.Q_INDEX
            wife.Q = normal_arr[wife.Q_INDEX]*p.sigma_4
        if decision.M == c.MARRIED:          # MARRIED WOMEN EMPLOYMENT BY KIDS INDIVIDUAL MOMENTS
          emp_m_kids[n_kids].accumulate(wife.WS, wife.emp_state) # employment married no kids
        else:
          # UNMARRIED WOMEN EMPLOYMENT BY KIDS INDIVIDUAL MOMENTS
          if n_kids == 0:
            emp_um_kids[0].accumulate(wife.WS, wife.emp_state) # un/employment unmarried and no children
          else:
            emp_um_kids[1].accumulate(wife.WS, wife.emp_state) # un/employment unmarried and no children
        # EMPLOYMENT TRANSITION MATRIX
        if wife.emp_state == c.EMP and prev_emp_state_w == c.UNEMP:
          # for transition matrix - unemployment to employment
          if decision.M == c.MARRIED:
            ++just_found_job_m[wife.WS]
            ++count_just_found_job_m[wife.WS]
            if n_kids >0:
              ++just_found_job_mc[wife.WS]
              ++count_just_found_job_mc[wife.WS]

          else:
            ++just_found_job_um[wife.WS]
            ++count_just_found_job_um[wife.WS]

        elif (wife.emp_state == c.UNEMP and prev_emp_state_w == c.EMP):
          # for transition matrix - employment to unemployment
          if decision.M == MARRIED:
            ++just_got_fired_m[wife.WS]
            if n_kids > 0:
              ++just_got_fired_mc[wife.WS]

          else:
            ++just_got_fired_um[wife.WS]

        elif wife.emp_state == c.UNEMP and prev_emp_state_w == c.UNEMP:
          # no change employment
          if decision.M == c.MARRIED:
            ++count_just_found_job_m[wife.WS]
            if n_kids > 0:
              ++count_just_found_job_mc[wife.WS]
          else:
            ++count_just_found_job_um[wife.WS]
        elif wife.emp_state == c.EMP and prev_emp_state_w == c.EMP:
          # no change unemployment
          if decision.M == c.MARRIED:
            ++count_just_got_fired_m[wife.WS]
            if n_kids > 0:
              ++count_just_got_fired_mc[wife.WS]
          else:
            ++count_just_got_fired_um[wife.WS]

        # women wages if employed by experience
        if wife.emp_state == c.EMP and wage_w > 0.0:
          wages_w.accumulate(wife.WE, school_group, wage_w)

        if decision.M == c.MARRIED:
          assert(wage_h > 0.0)   # husband always works
          wages_m_h.accumulate(husband.HE, husband.HS, wage_h) # husband always works
          if wife.WS > husband.HS:
            # women married down, men married up
            emp_m_down.accumulate(wife.WS, wife.emp_state)
            if husband.HE < 37  and wage_h > m.wage_moments[husband.HE][SCHOOL_LEN+husband.HS]:
              estimated.up_down_moments.accumulate(emp_m_down_above, wife.WS, wife.emp_state)
            else:
              estimated.up_down_moments.accumulate(emp_m_down_below, wife.WS, wife.emp_state)
            estimated.up_down_moments.accumulate(wages_m_h_up, husband.HS, wage_h)   # married up men wages
            if prev_M == c.UNMARRIED:
              # first period of marriage
              estimated.up_down_moments.accumulate(ability_h_up, husband.HS, husband.ability_h_value)
              estimated.up_down_moments.accumulate(ability_w_down, wife.WS, wife.ability_w_value)
              estimated.up_down_moments.accumulate(match_w_down, wife.WS, Q_minus_1)

          elif wife.WS < husband.HS:
            # women married up, men married down
            emp_m_up.accumulate(wife.WS, wife.emp_state)
            if husband.HE < 37 and wage_h > m.wage_moments[husband.HE][SCHOOL_LEN+husband.HS]:
              estimated.up_down_moments.accumulate(emp_m_up_above, wife.WS, wife.emp_state)
            else:
              estimated.up_down_moments.accumulate(emp_m_up_below, wife.WS, wife.emp_state)
            estimated.up_down_moments.accumulate(wages_m_h_down, husband.HS, wage_h)    # married down men wages
            if prev_M == c.UNMARRIED:
              # first period of marriage
              estimated.up_down_moments.accumulate(ability_h_down, husband.HS, husband.ability_h_value)
              estimated.up_down_moments.accumulate(ability_w_up, wife.WS, wife.ability_w_value)
              estimated.up_down_moments.accumulate(match_w_up, wife.WS, Q_minus_1)

          else:
            # married equal
            estimated.up_down_moments.accumulate(wages_m_h_eq, husband.HS, wage_h)  # married equal men wages
            emp_m_eq.accumulate(wife.WS, wife.emp_state)  #employment married equal women
            if husband.HE < 37 and wage_h > m.wage_moments[husband.HE][SCHOOL_LEN+husband.HS+husband.HS]:
              estimated.up_down_moments.accumulate(emp_m_eq_above, wife.WS,wife.emp_state)
            else:
              estimated.up_down_moments.accumulate(emp_m_eq_below, wife.WS, wife.emp_state)
            if prev_M == c.UNMARRIED:
              # first period of marriage
              estimated.up_down_moments.accumulate(ability_h_eq, husband.HS, husband.ability_h_value)
              estimated.up_down_moments.accumulate(ability_w_eq, wife.WS, wife.ability_w_value)
              estimated.up_down_moments.accumulate(match_w_eq, wife.WS, Q_minus_1)

        if wife.emp_state == c.EMP:
          # wife employed - emp_state is actually current state at this point
          if decision.M == c.MARRIED:
            estimated.wages_m_w.accumulate(wife.WE, school_group, wage_w)  # married women wages if employed
            if wife.WS < husband.HS:
              wages_m_w_up.accumulate(wife.WS, wage_w)                   # married up women wages if employed
            elif wife.WS > husband.HS:
              wages_m_w_down.accumulate(wife.WS, wage_w)                 # married down women wages if employed
            else:
              wages_m_w_eq.accumulate(wife.WS, wage_w)                   # married equal women wages if employed
          else:
            wages_um_w.accumulate(wife.WS, wage_w)                         # unmarried women wages if employed
        married[t+wife.age_index][school_group] += decision.M

        # FERTILITY AND MARRIED RATE MOMENTS
        newborn_all.accumulate(t+wife.age_index, wife.WS, new_born)
        if decision.M == c.MARRIED:
          newborn_m.accumulate(t+wife.age_index, wife.WS, new_born)
        else:
          newborn_um.accumulate(t+wife.age_index, wife.WS, new_born)
        if wife.AGE == MAX_FERTILITY_AGE - 4:
          n_kids_arr.accumulate(wife.WS, n_kids) # # of children by school group
          estimated.up_down_moments.accumulate(n_kids_m_arr, wife.WS, n_kids_m)
          estimated.up_down_moments.accumulate(n_kids_um_arr, wife.WS, n_kids_um)
        # marriage transition matrix
        if decision.M == c.MARRIED and prev_M == c.UNMARRIED:
          if verbose:
            print("decided to get married")
            draw_husband.print_husband(husband)
            draw_wife.print_wife(wife)
            print("kids: ", n_kids)
            print("husband wage:", wage_h)
            print("wife wage:", wage_w)

          # from single to married
          ++just_married[school_group]
          ++count_just_married[school_group]
          if first_marriage:
            age_at_first_marriage.accumulate(wife.WS, wife.AGE)
            ++assortative_mating_count[school_group]
            ++assortative_mating_hist[school_group][husband.HS]
            first_marriage = False
          assert(DIVORCE == 0)
        elif decision.M == c.UNMARRIED and prev_M == c.MARRIED:
          if verbose:
            print("decided to get divorced")
            print("utility:" , utility)
            draw_husband.print_husband(husband)
            draw_wife.print_wife(wife)
            print("kids: ", n_kids)
            print("husband wage:", wage_h)
            print("wife wage:", wage_w)
          # from married to divorce
          DIVORCE = 1
          ++just_divorced[school_group]
          ++count_just_divorced[school_group]
          if first_divorce:
            duration_of_first_marriage.accumulate(wife.WS, duration - 1) # duration of marriage if divorce
            first_divorce = False
        elif decision.M == c.MARRIED and prev_M == c.MARRIED:
          if verbose:
            print("still married")
            print("utility:", utility)
            draw_husband.print_husband(husband)
            draw_wife.print_wife(wife)
            print("kids: ", n_kids)
            print("husband wage:", wage_h)
            print("wife wage:", wage_w)
          # still married
          ++count_just_married[school_group]
          assert(DIVORCE == 0)
        elif decision.M == c.UNMARRIED and prev_M == c.UNMARRIED:
          # still unmarried
          if verbose:
            print("still divorced / single")
          ++count_just_divorced[school_group]
        divorce[t+wife.age_index][school_group] += DIVORCE
        ++wife.AGE
        ++husband.AGE
  # calculate employment moments
  for t in range(0, T_MAX):
    estimated.emp_moments[t][0] = t+18
    offset = 1
    for school_group in range(1,5):       # SCHOOL_W_VALUES
      estimated.emp_moments[t][offset] = mean(emp_total, count_emp_total, t, school_group)
      ++offset
    for school_group in range(1, 5):    #SCHOOL_W_VALUES
      estimated.emp_moments[t][offset] = mean(emp_m, married, t, school_group)
      ++offset
    for school_group in range(1, 5):    #SCHOOL_W_VALUES
      unmarried = c.DRAW_F - married[t][school_group]
      if unmarried == 0:
        estimated.emp_moments[t][offset] = 0.0
      else:
        estimated.emp_moments[t][offset] = emp_um[t][school_group]/unmarried
      ++offset

  # calculate marriage/fertility moments
  for t in range(0, T_MAX):
    estimated.marr_fer_moments[t][0] = t+18
    offset = 1
    for school_group in range(1, 5):    #SCHOOL_W_VALUES
      estimated.marr_fer_moments[t][offset] = married[t][school_group]/c.DRAW_F
      ++offset
    for school_group in range(1, 5):  # SCHOOL_W_VALUES
      estimated.marr_fer_moments[t][offset] = newborn_all.mean(t, school_group)
      ++offset
    for school_group in range(1, 5):    #SCHOOL_W_VALUES
      estimated.marr_fer_moments[t][offset] = divorce[t][school_group]/c.DRAW_F
      ++offset

  # calculate wage moments
  for t in range(0, T_MAX):
    estimated.wage_moments[t][0] = t
    offset = 1
    for WS in range(1, 5):    # SCHOOL_W_VALUES
      estimated.wage_moments[t][offset] = wages_w.mean(t, WS) 
      ++offset
    for HS in range(0,5):   # SCHOOL_H_VALUES
      estimated.wage_moments[t][offset] = wages_m_h.mean(t, HS)
      ++offset
  # calculate general moments
    # assortative mating
    row = 0
    for HS in range(0,5):   # SCHOOL_H_VALUES
      count = assortative_mating_count[HS]
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        if count == 0:
          estimated.general_moments[row][WS-1] = 0.0
        else:
          estimated.general_moments[row][WS-1] = assortative_mating_hist[WS][HS]/count
      ++row
    # first marriage duration
    for WS in range(1, 5):    # SCHOOL_W_VALUES
      estimated.general_moments[row][WS-1] = duration_of_first_marriage.mean(WS)
    ++row
    # age at first marriage
    for WS in range(1, 5):    # SCHOOL_W_VALUES
      estimated.general_moments[row][WS-1] = age_at_first_marriage.mean(WS)
    ++row
    # kids
    for WS in range(1, 5):    # SCHOOL_W_VALUES
      estimated.general_moments[row][WS-1] = n_kids_arr.mean(WS)
    ++row
    # women wage by match: UP, EQUAL, DOWN 
    for WS in range(1, 5):    # SCHOOL_W_VALUES
      estimated.general_moments[row][WS-1] = wages_m_w_up.mean(WS)
    ++row
    for WS in range(1, 5):    # SCHOOL_W_VALUES
      estimated.general_moments[row][WS-1] = wages_m_w_eq.mean(WS)
    ++row
    for WS in range(1, 5):    # SCHOOL_W_VALUES
      estimated.general_moments[row][WS-1] = wages_m_w_down.mean(WS)
    ++row
    # employment by match: UP, EQUAL, DOWN 
    for WS in range(1, 5):    # SCHOOL_W_VALUES
      estimated.general_moments[row][WS-1] = emp_m_up.mean(WS)
    ++row
    for WS in range(1, 5):    # SCHOOL_W_VALUES
      estimated.general_moments[row][WS-1] = emp_m_eq.mean(WS)
    ++row
    for WS in range(1, 5):    # SCHOOL_W_VALUES
      estimated.general_moments[row][WS-1] = emp_m_down.mean(WS)
    ++row
    # employment by childred: married with 0 - 4+ kids, unmarried with kids, unmarried with no kids
    for kids_n in range(0, M_KIDS_SIZE):
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        estimated.general_moments[row][WS-1] = emp_m_kids[kids_n].mean(WS)
      ++row
    for kids_n in range(0, M_KIDS_SIZE):
      for WS in range(1, 5):  # SCHOOL_W_VALUES
        estimated.general_moments[row][WS-1] = emp_um_kids[kids_n].mean(WS)
      ++row
    # employment transition matrix:
    for WS in range(1, 5):  # SCHOOL_W_VALUES
      estimated.general_moments[row][WS-1] = mean(just_got_fired_m, count_just_got_fired_m, WS)
    ++row
    for WS in range(1, 5):  # SCHOOL_W_VALUES
      estimated.general_moments[row][WS-1] = mean(just_found_job_m, count_just_found_job_m, WS)
    ++row
    for WS in range(1, 5):  # SCHOOL_W_VALUES
      estimated.general_moments[row][WS-1] = mean(just_got_fired_um, count_just_got_fired_um, WS)
    ++row
    for WS in range(1, 5):  # SCHOOL_W_VALUES
      estimated.general_moments[row][WS-1] = mean(just_found_job_um, count_just_found_job_um, WS)
    ++row
    for WS in range(1, 5):  # SCHOOL_W_VALUES
      estimated.general_moments[row][WS-1] = mean(just_got_fired_mc, count_just_got_fired_mc, WS)
    ++row
    for WS in range(1, 5):  # SCHOOL_W_VALUES
      estimated.general_moments[row][WS-1] = mean(just_found_job_mc, count_just_found_job_mc, WS)
    ++row
    # marriage transition matrix
    for WS in range(1, 5):  # SCHOOL_W_VALUES
      estimated.general_moments[row][WS-1] = mean(just_married, count_just_married, WS)
    ++row
    for WS in range(1, 5):  # SCHOOL_W_VALUES
      estimated.general_moments[row][WS-1] = mean(just_divorced, count_just_divorced, WS)
    ++row
    # birth rate unmarried and married
    for WS in range(1, 5):  # SCHOOL_W_VALUES
      estimated.general_moments[row][WS-1] = newborn_um.column_mean(WS)
    ++row
    for WS in range(1, 5):  # SCHOOL_W_VALUES
      estimated.general_moments[row][WS-1] = newborn_m.column_mean(WS)
  return estimated

def objective_function(m, m_stdev, display_moments, no_emax, adjust_bp, verbose, verbose_emax, prefix, infile, outfile):
  if no_emax == 0:
    t_start = time.monotonic()
    iter_count = calculate_emax(p, w_m_emax, h_m_emax, w_s_emax, h_s_emax, adjust_bp, verbose_emax)
    t_end = time.monotonic()
    print("emax calculation did ", iter_count, " iterations, over ")
#      << std::chrono::duration<double, std::milli>(t_end-t_start).count() << " milliseconds" << std::endl
    if outfile:
      dump_emax(prefix + "_married_women.csv", w_m_emax)
      dump_emax(prefix + "_married_men.csv", h_m_emax)
      dump_emax(prefix + "_single_women.csv", w_s_emax)
      dump_emax(prefix + "_single_men.csv", h_s_emax)

  else:
    print("running static model - no emax calculation")

  estimated_moments = calculate_moments(p, m, w_m_emax, h_m_emax, w_s_emax, h_s_emax, adjust_bp, verbose)

  if display_moments:
    up_down_mom_description = ["Married Up - Men's Ability",
      "Married Equal - Men's Ability",
      "Married Down - Men's Ability",
      "Married Up - Women's Ability",
      "Married Equal - Women's Ability",
      "Married Down - Women's Ability",
      "Married Up - Match Quality",
      "Married Equal - Match Quality",
      "Married Down - Match Quality",
      "Married Up - Men's Wage",
      "Married Equal - Men's Wage",
      "Married Down - Men's Wage",
      "Emp of Married Up - Men's Wage Above",
      "Emp of Married Up - Men's Wage Below",
      "Emp of Married Equal - Men's Wage Above",
      "Emp of Married Equal - Men's Wage Below",
      "Emp of Married Down - Men's Wage Above",
      "Emp of Married Down - Men's Wage Below",
      "# Kids for Married Women",
      "# Kids for Unmarried Women"]
    print(np.concatanate((up_down_mom_description, estimated_moments.up_down_moments), axis=1))

    dist_sum = np.sum(estimated_moments.bp_initial_dist)
    print(estimated_moments.bp_initial_dist/dist_sum)
    dist_sum = np.sum(estimated_moments.bp_dist)
    print(estimated_moments.bp_dist / dist_sum)
    dist_sum = np.sum(estimated_moments.cs_dist)
    print(estimated_moments.cs_dist / dist_sum)

    print("Wage Moments - Married Women")
    print(np.concatanate((estimated_moments.wage_moments[:,0:4], m.wage_moments[:, 0:4]), axis=1))
    print("Wage Moments - Married Men")
    print(np.concatanate((estimated_moments.wage_moments[:, 4:9], m.wage_moments[:, 4:9]), axis=1))

    print("Employment Moments - Total Women")
    print(np.concatanate((estimated_moments.emp_moments[:, 0:4], m.emp_moments[:, 0:4]), axis=1))
    print("Employment Moments - Married Women")
    print(np.concatanate((estimated_moments.emp_moments[:, 4:8], m.emp_moments[:, 4:8]), axis=1))
    print("Employment Moments - Unmarried Women")
    print(np.concatanate((estimated_moments.emp_moments[:, 8:12], m.emp_moments[:, 8:12]), axis=1))

    print("Marriage Rate")
    print(np.concatanate((estimated_moments.mar_fer_moments[:, 0:4], m.mar_fer_moments[:, 0:4]), axis=1))
    print("Fertility Rate")
    print(np.concatanate((estimated_moments.mar_fer_moments[:, 4:8], m.mar_fer_moments[:, 4:8]), axis=1))
    print("Divorce Rate")
    print(np.concatanate((estimated_moments.mar_fer_moments[:, 8:12], m.mar_fer_moments[:, 8:12]), axis=1))
    gen_mom_description = ["Assortative Mating - HSD",
      "Assortative Mating - HSG",
      "Assortative Mating - SC",
      "Assortative Mating - CG",
      "Assortative Mating - PC",
      "Marriage Duration",
      "Age at 1st Marriage",
      "Kids",
      "Wage - Married Up",
      "Wage - Married Equal",
      "Wage - Married Down",
      "Emp - Married Up",
      "Emp - Married Equal",
      "Emp - Married Down",
      "Emp - Married No kids",
      "Emp - Married 1 kid",
      "Emp - Married 2 kids",
      "Emp - Married 3 kids",
      "Emp - Married 4+ kids",
      "Emp - Unmarried No kids",
      "Emp - Unmarried 1+ kid",
      "Emp->Unemp - Married",
      "Unemp->Emp - Married",
      "Emp->Unemp - Unmarried",
      "Unemp->Emp - Unmarried",
      "Emp->Unemp - Married+",
      "Unemp->Emp - Married+",
      "Unmarried->Married",
      "Married->Unmarried",
      "Birth Rate - Married",
      "Birth Rate - Unarried"]
    print(np.concatanate((gen_mom_description, estimated_moments.general_moments, m.general_moments), axis=1))

  # objective function calculation:
  # (1) calculate MSE for each moment that has a time dimension and normalize by its standard deviation
  #     note that the first column of the moments (index) is skipped
  # (2) for general moments, each one is normalize by its standard deviation
  # (3) the value of the objective function is the sum of all the values in (1) and (2)

  wage_moments_mse = MSE(estimated_moments.wage_moments, m.wage_moments)
  mse_normalize(wage_moments_mse, m_stdev.wage_moments_stdev)

  marr_fer_moments_mse = MSE(estimated_moments.marr_fer_moments, m.marr_fer_moments)
  mse_normalize(marr_fer_moments_mse, m_stdev.marr_fer_moments_stdev)

  emp_moments_mse = MSE(estimated_moments.emp_moments, m.emp_moments)
  mse_normalize(emp_moments_mse, m_stdev.emp_moments_stdev)

  general_moments_mse = divide(square_diff(estimated_moments.general_moments, m.general_moments), m_stdev.general_moments_stdev)

  value = (mse_nansum(wage_moments_mse) + mse_nansum(marr_fer_moments_mse) + mse_nansum(emp_moments_mse) +
    total_nansum(general_moments_mse))

  return value


