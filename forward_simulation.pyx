import numpy as np
import math
from statistics import NormalDist
cimport parameters as p
cimport constant_parameters as c
cimport draw_husband
cimport draw_wife
cimport calculate_wage
from calculate_utility cimport calculate_utility, Utility
cimport nash
cimport marriage_emp_decision
from moments import Moments, UpDownMomentsType, calculate_moments


def forward_simulation(w_m_emax, h_m_emax, w_s_emax, h_s_emax, adjust_bp, verbose, display_moments):
  m = Moments()
  # school_group 0 is only for calculating the emax if single men - not used here
  for school_group in range(1, 5):       # SCHOOL_W_VALUES
    for draw_f in range(0, c.DRAW_F):   # start the forward loop
      IGNORE_T = 0
      husband = draw_husband.Husband()  # declare husband structure
      wife = draw_wife.Wife()           # declare wife structure
      draw_wife.update_ability(np.random.random_integers(0, 2), wife)
      if draw_f > c.DRAW_F*c.UNEMP_WOMEN_RATIO:
        # update previous employment status according to proportion in population
        wife.set_emp_state(c.UNEMP)
      else:
        wife.set_emp_state(c.EMP)
      # kid age array maximum number of kids = 4 -  0 - oldest kid ... 3 - youngest kid
      kid_age = np.zeros(c.MAX_NUM_KIDS)
      DIVORCE = 0
      n_kids = 0
      n_kids_m = 0
      n_kids_um = 0
      duration = 0
      Q_minus_1 = 0.0
      bp = c.INITIAL_BP
      draw_wife.update_ability(np.random.random_integers(0, 2), wife)
      decision = marriage_emp_decision.MarriageEmpDecision()

      # following 2 indicators are used to count age at first marriage
      # and marriage duration only once per draw
      first_marriage = True
      first_divorce = True
      # make choices for all periods
      last_t = wife.get_T_END()
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
          choose_husband_p = (math.exp(p.p0_w + p.p1_w * wife.AGE + p.p2_w * pow(wife.AGE, 2)) /
                              (1.0 + math.exp(p.p0_w + p.p1_w * wife.AGE + p.p2_w * pow(wife.AGE, 2))))
          if np.random.uniform(0, 1) < choose_husband_p:
            choose_husband = True
            husband = draw_husband.draw_husband(t, wife, True)
            wife.Q_INDEX = np.random.random_integers(0, 2)  # draw wife's
            wife.Q = c.normal_arr[wife.Q_INDEX] * p.sigma4
            draw_husband.update_school_and_age_f(wife, husband)
            assert(husband.AGE == wife.AGE)
            if verbose:
              print("new potential husband")

        # potential or current husband wage
        if decision.M == c.MARRIED or choose_husband:
          wage_h = calculate_wage.calculate_wage_h(husband, np.random.normal(0, 1))
        else:
          wage_h = 0.0
        wage_w = calculate_wage.calculate_wage_w(wife, np.random.uniform(), np.random.normal(0, 1))
        is_single_men = False
        if decision.M == c.UNMARRIED and choose_husband:          # not married, but has potential husband - calculate initial BP
          utility = calculate_utility(w_m_emax, h_m_emax, w_s_emax, h_s_emax, n_kids, wage_h, wage_w,
            True, decision.M, wife, husband, t, bp, is_single_men)
          # Nash bargaining at first period of marriage
          bp = nash.nash(utility)
        if bp != c.NO_BP:
          m.bp_initial_dist[bp*10] += 1
        else:
          choose_husband = False

        if decision.M == c.MARRIED:
          if verbose:
            print("existing husband")
        utility = Utility()
        if decision.M == c.MARRIED or choose_husband:
          # at this point the BP is 0.5 if there is no marriage offer
          # BP is calculated by nash above if offer given
          # and is from previous period if already married
          # utility is calculated again based on the new BP
          utility = calculate_utility(w_m_emax, h_m_emax, w_s_emax, h_s_emax, n_kids, wage_h, wage_w,
              True, decision.M, wife, husband, t, bp, is_single_men)
          decision = marriage_emp_decision.marriage_emp_decision(utility, bp, wife, husband, adjust_bp)
        else:
          assert(wage_h == 0.0)
          utility = calculate_utility(w_m_emax, h_m_emax, w_s_emax, h_s_emax, n_kids, wage_h, wage_w,
              False, decision.M, wife, husband, t, bp, is_single_men)
          wife.emp_state = marriage_emp_decision.wife_emp_decision(utility)
        assert(t+wife.age_index < c.T_MAX)
        m.emp_total[t+wife.age_index][school_group] += wife.emp_state
        if decision.M == c.MARRIED:
          m.emp_m[t+wife.age_index][school_group] += wife.emp_state
        if decision.M == c.UNMARRIED:
          m.emp_um[t+wife.age_index][school_group] += wife.emp_state
          m.count_emp_total[t+wife.age_index][school_group] += 1
        if bp != c.NO_BP:
          m.bp_dist[bp*10] += 1
        if decision.M == c.MARRIED:
          m.cs_dist[decision.max_weighted_utility_index] += 1
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
        c_lambda = (p.c1 * wife.emp_state + p.c2 * wife.HSG * wife.AGE + p.c3 * wife.HSG * pow(wife.AGE, 2) +
                   p.c4 * wife.SC * wife.AGE + p.c5 * wife.SC * pow(wife.AGE, 2) + p.c6 * wife.CG * wife.AGE + p.c7 * wife.CG * pow(wife.AGE, 2) +
                   p.c8 * wife.PC * wife.AGE + p.c9 * wife.PC * pow(wife.AGE, 2) + p.c10 * n_kids + p.c11 * husband.HS * decision.M + p.c12 * decision.M)
        child_prob = NormalDist(mu=0, sigma=1).pdf(c_lambda)
        if np.random.uniform(0, 1) < child_prob and wife.AGE < c.MAX_FERTILITY_AGE:
          new_born = 1
          n_kids = min(n_kids+1, c.MAX_NUM_KIDS)
          if decision.M == c.MARRIED:
            n_kids_m = min(n_kids_m+1, c.MAX_NUM_KIDS)
          else:
            n_kids_um = min(n_kids_um+1, c.MAX_NUM_KIDS)
          # set the age for the youngest kid
          assert(n_kids>0)
          assert(n_kids <= c.MAX_NUM_KIDS)
          kid_age[n_kids-1] = 1
        elif n_kids > 0:
          # no newborn, but kids at house, so update ages
          if kid_age[0] == 18:
            # oldest kids above 18 leaves the household
            for order in range(0, c.MAX_NUM_KIDS-1):
              kid_age[order] = kid_age[order+1]
            kid_age[c.MAX_NUM_KIDS-1] = 0
            n_kids = n_kids -1
            assert(n_kids>=0)
          for order in range(0, c.MAX_NUM_KIDS):
            if kid_age[order] > 0:
              kid_age[order] += 1
        # update the match quality
        if decision.M == c.MARRIED:
          Q_minus_1 = wife.Q
          DIVORCE = 0
          duration += 1
          match_quality_change_prob = np.random.uniform(0, 1)
          if match_quality_change_prob < p.MATCH_Q_DECREASE and wife.Q_INDEX > 0:
            wife.Q_INDEX -= 1
            wife.Q = c.normal_arr[wife.Q_INDEX]*p.sigma4
          elif p.MATCH_Q_DECREASE < match_quality_change_prob < p.MATCH_Q_DECREASE + p.MATCH_Q_INCREASE and wife.Q_INDEX < 2:
            wife.Q_INDEX -= 1
            wife.Q = c.normal_arr[wife.Q_INDEX]*p.sigma4
        if decision.M == c.MARRIED:          # MARRIED WOMEN EMPLOYMENT BY KIDS INDIVIDUAL MOMENTS
          m.emp_m_kids[n_kids].accumulate(wife.WS, wife.emp_state)  # employment married no kids
        else:
          # UNMARRIED WOMEN EMPLOYMENT BY KIDS INDIVIDUAL MOMENTS
          if n_kids == 0:
            m.emp_um_kids[0].accumulate(wife.WS, wife.emp_state) # un/employment unmarried and no children
          else:
            m.emp_um_kids[1].accumulate(wife.WS, wife.emp_state) # un/employment unmarried and no children
        # EMPLOYMENT TRANSITION MATRIX
        if wife.emp_state == c.EMP and prev_emp_state_w == c.UNEMP:
          # for transition matrix - unemployment to employment
          if decision.M == c.MARRIED:
            m.just_found_job_m[wife.WS] += 1
            m.count_just_found_job_m[wife.WS] += 1
            if n_kids >0:
              m.just_found_job_mc[wife.WS] += 1
              m.count_just_found_job_mc[wife.WS] += 1
          else:
            m.just_found_job_um[wife.WS] += 1
            m.count_just_found_job_um[wife.WS] += 1
        elif wife.emp_state == c.UNEMP and prev_emp_state_w == c.EMP:
          # for transition matrix - employment to unemployment
          if decision.M == c.MARRIED:
            m.just_got_fired_m[wife.WS] += 1
            if n_kids > 0:
              m.just_got_fired_mc[wife.WS] += 1
          else:
            m.just_got_fired_um[wife.WS] += 1
        elif wife.emp_state == c.UNEMP and prev_emp_state_w == c.UNEMP:
          # no change employment
          if decision.M == c.MARRIED:
            m.count_just_found_job_m[wife.WS] += 1
            if n_kids > 0:
              m.count_just_found_job_mc[wife.WS] += 1
          else:
            m.count_just_found_job_um[wife.WS] += 1
        elif wife.emp_state == c.EMP and prev_emp_state_w == c.EMP:
          # no change unemployment
          if decision.M == c.MARRIED:
            m.count_just_got_fired_m[wife.WS] += 1
            if n_kids > 0:
              m.count_just_got_fired_mc[wife.WS] += 1
          else:
            m.count_just_got_fired_um[wife.WS] += 1

        # women wages if employed by experience
        if wife.emp_state == c.EMP and wage_w > 0.0:
          m.wages_w.accumulate(wage_w, wife.WE, school_group)

        if decision.M == c.MARRIED:
          assert(wage_h > 0.0)   # husband always works
          m.wages_m_h.accumulate(wage_h, husband.HE, husband.HS) # husband always works
          if wife.WS > husband.HS:
            # women married down, men married up
            m.emp_m_down.accumulate(wife.WS, wife.emp_state)
            if husband.HE < 37 and wage_h > m.wage_moments[husband.HE][c.SCHOOL_SIZE+husband.HS]:
              m.up_down_moments.accumulate(UpDownMomentsType.emp_m_down_above, wife.WS, wife.emp_state)
            else:
              m.up_down_moments.accumulate(UpDownMomentsType.emp_m_down_below, wife.WS, wife.emp_state)
            m.up_down_moments.accumulate(UpDownMomentsType.wages_m_h_up, husband.HS, wage_h)   # married up men wages
            if prev_M == c.UNMARRIED:
              # first period of marriage
              m.up_down_moments.accumulate(UpDownMomentsType.ability_h_up, husband.HS, husband.ability_h_value)
              m.up_down_moments.accumulate(UpDownMomentsType.ability_w_down, wife.WS, wife.ability_w_value)
              m.up_down_moments.accumulate(UpDownMomentsType.match_w_down, wife.WS, Q_minus_1)
          elif wife.WS < husband.HS:
            # women married up, men married down
            m.emp_m_up.accumulate(wife.WS, wife.emp_state)
            if husband.HE < 37 and wage_h > m.wage_moments[husband.HE][c.SCHOOL_SIZE+husband.HS]:
              m.up_down_moments.accumulate(UpDownMomentsType.emp_m_up_above, wife.WS, wife.emp_state)
            else:
              m.up_down_moments.accumulate(UpDownMomentsType.emp_m_up_below, wife.WS, wife.emp_state)
            m.up_down_moments.accumulate(UpDownMomentsType.wages_m_h_down, husband.HS, wage_h)    # married down men wages
            if prev_M == c.UNMARRIED:
              # first period of marriage
              m.up_down_moments.accumulate(UpDownMomentsType.ability_h_down, husband.HS, husband.ability_h_value)
              m.up_down_moments.accumulate(UpDownMomentsType.ability_w_up, wife.WS, wife.ability_w_value)
              m.up_down_moments.accumulate(UpDownMomentsType.match_w_up, wife.WS, Q_minus_1)
          else:
            # married equal
            m.up_down_moments.accumulate(UpDownMomentsType.wages_m_h_eq, husband.HS, wage_h)  # married equal men wages
            m.emp_m_eq.accumulate(wife.WS, wife.emp_state)  #employment married equal women
            if husband.HE < 37 and wage_h > m.wage_moments[husband.HE][c.SCHOOL_SIZE+husband.HS+husband.HS]:
              m.up_down_moments.accumulate(UpDownMomentsType.emp_m_eq_above, wife.WS,wife.emp_state)
            else:
              m.up_down_moments.accumulate(UpDownMomentsType.emp_m_eq_below, wife.WS, wife.emp_state)
            if prev_M == c.UNMARRIED:
              # first period of marriage
              m.up_down_moments.accumulate(UpDownMomentsType.ability_h_eq, husband.HS, husband.ability_h_value)
              m.up_down_moments.accumulate(UpDownMomentsType.ability_w_eq, wife.WS, wife.ability_w_value)
              m.up_down_moments.accumulate(UpDownMomentsType.match_w_eq, wife.WS, Q_minus_1)

        if wife.emp_state == c.EMP:
          # wife employed - emp_state is actually current state at this point
          if decision.M == c.MARRIED:
            m.estimated.wages_m_w.accumulate(wife.WE, school_group, wage_w)  # married women wages if employed
            if wife.WS < husband.HS:
              m.wages_m_w_up.accumulate(wife.WS, wage_w)                   # married up women wages if employed
            elif wife.WS > husband.HS:
              m.wages_m_w_down.accumulate(wife.WS, wage_w)                 # married down women wages if employed
            else:
              m.wages_m_w_eq.accumulate(wife.WS, wage_w)                   # married equal women wages if employed
          else:
            m.wages_um_w.accumulate(wife.WS, wage_w)                         # unmarried women wages if employed
        m.married[t+wife.age_index][school_group] += decision.M

        # FERTILITY AND MARRIED RATE MOMENTS
        m.newborn_all.accumulate(t+wife.age_index, wife.WS, new_born)
        if decision.M == c.MARRIED:
          m.newborn_m.accumulate(t+wife.age_index, wife.WS, new_born)
        else:
          m.newborn_um.accumulate(t+wife.age_index, wife.WS, new_born)
        if wife.AGE == c.MAX_FERTILITY_AGE - 4:
          m.n_kids_arr.accumulate(wife.WS, n_kids) # # of children by school group
          m.up_down_moments.accumulate(UpDownMomentsType.n_kids_m_arr, wife.WS, n_kids_m)
          m.up_down_moments.accumulate(UpDownMomentsType.n_kids_um_arr, wife.WS, n_kids_um)
        # marriage transition matrix
        if decision.M == c.MARRIED and prev_M == c.UNMARRIED:
          if verbose:
            print("decided to get married")
            print(husband)
            print(wife)
            print("kids: ", n_kids)
            print("husband wage:", wage_h)
            print("wife wage:", wage_w)

          # from single to married
          m.just_married[school_group] += 1
          m.count_just_married[school_group] += 1
          if first_marriage:
            m.age_at_first_marriage.accumulate(wife.WS, wife.AGE)
            m.assortative_mating_count[school_group] += 1
            m.assortative_mating_hist[school_group][husband.HS] += 1
            first_marriage = False
          assert(DIVORCE == 0)
        elif decision.M == c.UNMARRIED and prev_M == c.MARRIED:
          if verbose:
            print("decided to get divorced")
            print("utility:" , utility)
            print(husband)
            print(wife)
            print("kids: ", n_kids)
            print("husband wage:", wage_h)
            print("wife wage:", wage_w)
          # from married to divorce
          DIVORCE = 1
          m.just_divorced[school_group] += 1
          m.count_just_divorced[school_group] += 1
          if first_divorce:
            m.duration_of_first_marriage.accumulate(wife.WS, duration - 1) # duration of marriage if divorce
            first_divorce = False
        elif decision.M == c.MARRIED and prev_M == c.MARRIED:
          if verbose:
            print("still married")
            print("utility:", utility)
            print(husband)
            print(wife)
            print("kids: ", n_kids)
            print("husband wage:", wage_h)
            print("wife wage:", wage_w)
          # still married
          m.count_just_married[school_group] += 1
          assert(DIVORCE == 0)
        elif decision.M == c.UNMARRIED and prev_M == c.UNMARRIED:
          # still unmarried
          if verbose:
            print("still divorced / single")
          m.count_just_divorced[school_group] += 1
        m.divorce[t+wife.age_index][school_group] += DIVORCE
        wife.AGE += 1
        husband.AGE += 1

  estimated_moments = calculate_moments(m ,display_moments)

  # objective function calculation:
  # (1) calculate MSE for each moment that has a time dimension and normalize by its standard deviation
  #     note that the first column of the moments (index) is skipped
  # (2) for general moments, each one is normalized by its standard deviation
  # (3) the value of the objective function is the sum of all the values in (1) and (2)
  return 0.0


