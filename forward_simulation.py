import numpy as np
import math
from statistics import NormalDist
import parameters1 as p
import constant_parameters as c
import draw_husband
import draw_wife
import calculate_wage
from calculate_utility import calculate_utility, Utility
import nash
from marriage_emp_decision import marriage_emp_decision, wife_emp_decision
from moments import Moments, UpDownMomentsType, calculate_moments

UNEMP = c.F_UNEMP
EMP = c.F_EMP
UNMARRIED = c.F_UNMARRIED
MARRIED = c.F_MARRIED
SCHOOL_SIZE = c.F_SCHOOL_SIZE
INITIAL_BP = c.F_INITIAL_BP
NO_BP = c.F_NO_BP
T_MAX = c.F_T_MAX
MAX_FERTILITY_AGE = c.F_MAX_FERTILITY_AGE
CS_SIZE = c.F_CS_SIZE


def forward_simulation(w_m_emax, h_m_emax, w_s_emax, h_s_emax, adjust_bp, verbose, display_moments):
  m = Moments()
  # school_group 0 is only for calculating the emax if single men - not used here
  for school_group in range(1, SCHOOL_SIZE):       # SCHOOL_W_VALUES - 1, 2, 3 , 4
    for draw_f in range(0, c.DRAW_F):   # start the forward loop
      husband = draw_husband.Husband()  # declare husband structure
      wife = draw_wife.Wife()           # declare wife structure
      draw_wife.update_wife_schooling(school_group, 0, wife)
      draw_wife.update_ability(np.random.random_integers(0, 2), wife)
      if draw_f > c.DRAW_F*c.UNEMP_WOMEN_RATIO:
        # update previous employment status according to proportion in population
        wife.set_emp_state(UNEMP)
      else:
        wife.set_emp_state(EMP)
      # kid age array maximum number of kids = 4 -  0 - oldest kid ... 3 - youngest kid
      kid_age = np.zeros(c.MAX_NUM_KIDS)
      DIVORCE = 0
      n_kids = 0
      n_kids_m = 0
      n_kids_um = 0
      duration = 0
      bp = INITIAL_BP
      M = UNMARRIED
      max_weighted_utility_index = 0

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
        print(wife)
      # FIXME: husband moments are calculated up to last_t and not T_MAX
      for t in range(0, last_t):
        if verbose:
          print("========= ", t, " =========")
        w_prev_emp_state = wife.get_emp_state()
        prev_M = M
        new_born = 0
        choose_husband = False
        # draw husband if not already married
        if M == UNMARRIED:
          bp = INITIAL_BP
          duration = 0
          wife.set_Q(0)
          # probability of meeting a potential husband
          choose_husband_p = (math.exp(p.p0_w + p.p1_w * wife.get_AGE() + p.p2_w * pow(wife.get_AGE(), 2)) /
                              (1.0 + math.exp(p.p0_w + p.p1_w * wife.get_AGE() + p.p2_w * pow(wife.get_AGE(), 2))))
          if np.random.uniform(0, 1) < choose_husband_p:
            choose_husband = True
            husband = draw_husband.draw_husband(t, wife, True)
            #print(husband)
            wife.set_Q(np.random.random_integers(0, 2))  # draw wife's match quality
            assert(husband.get_AGE() == wife.get_AGE())
            if verbose:
              print("new potential husband")

        # potential or current husband wage
        if M == MARRIED or choose_husband:
          wage_h = calculate_wage.calculate_wage_h(husband, np.random.normal(0, 1))
        else:
          wage_h = 0.0
        wage_w = calculate_wage.calculate_wage_w(wife, np.random.uniform(), np.random.normal(0, 1))
        is_single_men = False
        if M == UNMARRIED and choose_husband:          # not married, but has potential husband - calculate initial BP
          utility = calculate_utility(w_m_emax, h_m_emax, w_s_emax, h_s_emax, n_kids, wage_h, wage_w,
            True, M, wife, husband, t, bp, is_single_men)
          # Nash bargaining at first period of marriage
          bp = nash.nash(utility)
        if bp != NO_BP:
          m.bp_initial_dist[int(bp*10)] = m.bp_initial_dist[int(bp*10)] + 1
        else:
          choose_husband = False

        if M == MARRIED:
          if verbose:
            print("existing husband")
            print(husband)
        utility = Utility()
        if M == MARRIED or choose_husband:
          # at this point the BP is 0.5 if there is no marriage offer
          # BP is calculated by nash above if offer given
          # and is from previous period if already married
          # utility is calculated again based on the new BP
          utility = calculate_utility(w_m_emax, h_m_emax, w_s_emax, h_s_emax, n_kids, wage_h, wage_w,
              True, M, wife, husband, t, bp, is_single_men)
          M, max_weighted_utility_index, _, _, _ = marriage_emp_decision(utility, bp, wife, husband, adjust_bp)
        else:   # unmarried and no potential husband
          # assert(wage_h == 0.0)
          utility = calculate_utility(w_m_emax, h_m_emax, w_s_emax, h_s_emax, n_kids, wage_h, wage_w,
              False, M, wife, husband, t, bp, is_single_men)
          wife.set_emp_state(wife_emp_decision(utility))
        assert(t+wife.get_age_index() < T_MAX)
        w_emp_state = wife.get_emp_state()
        age_index = wife.get_age_index()
        m.emp_total[t+age_index][school_group] += w_emp_state
        m.count_emp_total[t + age_index][school_group] += 1
        if M == MARRIED:
          m.emp_m[t+age_index][school_group] += w_emp_state
        if M == UNMARRIED:
          m.emp_um[t+age_index][school_group] += w_emp_state
        if bp != NO_BP:
          m.bp_dist[int(bp*10)] += 1
        if M == MARRIED:
          m.cs_dist[max_weighted_utility_index%CS_SIZE] += 1
        c_lambda = wife.calculate_lambda(n_kids, husband.get_HS(), M)
        child_prob = NormalDist(mu=0, sigma=1).pdf(c_lambda)
        if np.random.uniform(0, 1) < child_prob and wife.get_AGE() < MAX_FERTILITY_AGE:
          new_born = 1
          n_kids = min(n_kids+1, c.MAX_NUM_KIDS)
          if M == MARRIED:
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
        WS = wife.get_WS()

        if M == MARRIED:
          DIVORCE = 0
          duration += 1
          match_quality_change_prob = np.random.uniform(0, 1)
          if match_quality_change_prob < p.MATCH_Q_DECREASE and wife.Q_INDEX > 0:
            wife.decrease_Q()
          elif p.MATCH_Q_DECREASE < match_quality_change_prob < p.MATCH_Q_DECREASE + p.MATCH_Q_INCREASE and wife.Q_INDEX < 2:
            # FIXME: should be "increase"?
            wife.increase_Q()
        if M == MARRIED:          # MARRIED WOMEN EMPLOYMENT BY KIDS INDIVIDUAL MOMENTS
          m.emp_m_kids[n_kids].accumulate(WS, w_emp_state)  # employment married by kids
        else:
          # UNMARRIED WOMEN EMPLOYMENT BY KIDS INDIVIDUAL MOMENTS
          if n_kids == 0:
            m.emp_um_kids[0].accumulate(WS, w_emp_state) # un/employment unmarried and no children
          else:
            m.emp_um_kids[1].accumulate(WS, w_emp_state) # un/employment unmarried and no children
        # EMPLOYMENT TRANSITION MATRIX
        if w_emp_state == EMP and w_prev_emp_state == UNEMP:
          # for transition matrix - unemployment to employment
          if M == MARRIED:
            m.just_found_job_m[WS] += 1
            m.count_just_found_job_m[WS] += 1
            if n_kids > 0:
              m.just_found_job_mc[WS] += 1
              m.count_just_found_job_mc[WS] += 1
          else:
            m.just_found_job_um[WS] += 1
            m.count_just_found_job_um[WS] += 1
        elif w_emp_state == UNEMP and w_prev_emp_state == EMP:
          # for transition matrix - employment to unemployment
          if M == MARRIED:
            m.just_got_fired_m[WS] += 1
            if n_kids > 0:
              m.just_got_fired_mc[WS] += 1
          else:
            m.just_got_fired_um[WS] += 1
        elif w_emp_state == UNEMP and w_prev_emp_state == UNEMP:
          # no change employment
          if M == MARRIED:
            m.count_just_found_job_m[WS] += 1
            if n_kids > 0:
              m.count_just_found_job_mc[WS] += 1
          else:
            m.count_just_found_job_um[WS] += 1
        elif w_emp_state == EMP and w_prev_emp_state == EMP:
          # no change unemployment
          if M == MARRIED:
            m.count_just_got_fired_m[WS] += 1
            if n_kids > 0:
              m.count_just_got_fired_mc[WS] += 1
          else:
            m.count_just_got_fired_um[WS] += 1

        # women wages if employed by experience
        if w_emp_state == EMP and wage_w > 0.0:
          m.wages_w.accumulate(wage_w, wife.get_WE(), school_group)

        if M == MARRIED:
          assert(wage_h > 0.0)   # husband always works
          m.wages_m_h.accumulate(wage_h, husband.get_HE(), husband.get_HS()) # husband always works
          if WS > husband.get_HS():
            # women married down, men married up
            m.emp_m_down.accumulate(WS, w_emp_state)
            # TODO: how to use wage_moments ?
            #if husband.HE < 37 and wage_h > m.wage_moments[husband.HE][SCHOOL_SIZE+husband.HS]:
            #  m.up_down_moments.accumulate(UpDownMomentsType.emp_m_down_above, WS, w_emp_state)
            #else:
            #  m.up_down_moments.accumulate(UpDownMomentsType.emp_m_down_below, WS, w_emp_state)
            #m.up_down_moments.accumulate(UpDownMomentsType.wages_m_h_up, husband.HS, wage_h)   # married up men wages
            #if prev_M == UNMARRIED:
              # first period of marriage
              #m.up_down_moments.accumulate(UpDownMomentsType.ability_h_up, husband.HS, husband.ability_h_value)
              #m.up_down_moments.accumulate(UpDownMomentsType.ability_w_down, WS, wife.ability_w_value)
              #m.up_down_moments.accumulate(UpDownMomentsType.match_w_down, WS, wife.get_Q())
          #elif WS < husband.HS:
            # women married up, men married down
            #m.emp_m_up.accumulate(WS, w_emp_state)
            # TODO: how to use wage_moments ?
            #if husband.HE < 37 and wage_h > m.wage_moments[husband.HE][SCHOOL_SIZE+husband.HS]:
            #  m.up_down_moments.accumulate(UpDownMomentsType.emp_m_up_above, WS, w_emp_state)
            #else:
            #  m.up_down_moments.accumulate(UpDownMomentsType.emp_m_up_below, WS, w_emp_state)
            #m.up_down_moments.accumulate(UpDownMomentsType.wages_m_h_down, husband.HS, wage_h)    # married down men wages
            #if prev_M == UNMARRIED:
              # first period of marriage
              #m.up_down_moments.accumulate(UpDownMomentsType.ability_h_down, husband.HS, husband.ability_h_value)
              #m.up_down_moments.accumulate(UpDownMomentsType.ability_w_up, WS, wife.ability_w_value)
              #m.up_down_moments.accumulate(UpDownMomentsType.match_w_up, WS, wife.get_Q())
          else:
            # married equal
            #m.up_down_moments.accumulate(UpDownMomentsType.wages_m_h_eq, husband.HS, wage_h)  # married equal men wages
            m.emp_m_eq.accumulate(WS, w_emp_state)  #employment married equal women
            # TODO: how to use wage_moments ?
            #if husband.HE < 37 and wage_h > m.wage_moments[husband.HE][SCHOOL_SIZE+husband.HS+husband.HS]:
            #  m.up_down_moments.accumulate(UpDownMomentsType.emp_m_eq_above, WS,w_emp_state)
            #else:
            #  m.up_down_moments.accumulate(UpDownMomentsType.emp_m_eq_below, WS, w_emp_state)
            #if prev_M == UNMARRIED:
              # first period of marriage
              #m.up_down_moments.accumulate(UpDownMomentsType.ability_h_eq, husband.HS, husband.ability_h_value)
              #m.up_down_moments.accumulate(UpDownMomentsType.ability_w_eq, WS, wife.ability_w_value)
              #m.up_down_moments.accumulate(UpDownMomentsType.match_w_eq, WS, wife.get_Q())

        if w_emp_state == EMP:
          # wife employed - emp_state is actually current state at this point
          if M == MARRIED:
            m.wages_w.accumulate(wage_w, wife.get_WE(), school_group)  # married women wages if employed
            if WS < husband.get_HS():
              m.wages_m_w_up.accumulate(wage_w, WS)                   # married up women wages if employed
            elif WS > husband.get_HS():
              m.wages_m_w_down.accumulate(wage_w, WS)                 # married down women wages if employed
            else:
              m.wages_m_w_eq.accumulate(wage_w, WS)                   # married equal women wages if employed
          else:
            m.wages_um_w.accumulate(wage_w, WS)                         # unmarried women wages if employed
        w_age_index = wife.get_age_index()
        m.married[t+w_age_index][school_group] += M

        # FERTILITY AND MARRIED RATE MOMENTS
        m.newborn_all.accumulate(t+w_age_index, WS, new_born)
        if M == MARRIED:
          m.newborn_m.accumulate(t+w_age_index, WS, new_born)
        else:
          m.newborn_um.accumulate(t+w_age_index, WS, new_born)
        if wife.get_AGE() == MAX_FERTILITY_AGE - 4:
          m.n_kids_arr.accumulate(WS, n_kids) # # of children by school group
          #m.up_down_moments.accumulate(UpDownMomentsType.n_kids_m_arr, WS, n_kids_m)
          #m.up_down_moments.accumulate(UpDownMomentsType.n_kids_um_arr, WS, n_kids_um)
        # marriage transition matrix
        if M == MARRIED and prev_M == UNMARRIED:
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
            m.age_at_first_marriage.accumulate(wife.get_AGE(), WS)
            m.assortative_mating_count[school_group] += 1
            m.assortative_mating_hist[husband.get_HS()][school_group] += 1
            first_marriage = False
          assert(DIVORCE == 0)
        elif M == UNMARRIED and prev_M == MARRIED:
          if verbose:
            print("decided to get divorced")
            print("utility:", utility)
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
            m.duration_of_first_marriage.accumulate(duration, WS-1) # duration of marriage if divorce
            first_divorce = False
        elif M == MARRIED and prev_M == MARRIED:
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
        elif M == UNMARRIED and prev_M == UNMARRIED:
          # still unmarried
          if verbose:
            print("still divorced / single")
          m.count_just_divorced[school_group] += 1

        m.divorce[t+w_age_index][school_group] += DIVORCE
        wife.increase_AGE()
        husband.increase_AGE()

  estimated_moments = calculate_moments(m, display_moments)

  # objective function calculation:
  # (1) calculate MSE for each moment that has a time dimension and normalize by its standard deviation
  #     note that the first column of the moments (index) is skipped
  # (2) for general moments, each one is normalized by its standard deviation
  # (3) the value of the objective function is the sum of all the values in (1) and (2)
  return 0.0
