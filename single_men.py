import math
import parameters as p
import constant_parameters as c
from random_pool import epsilon
from random_pool import draw_p
import draw_husband
import draw_wife
import calculate_wage
import calculate_utility
import marriage_emp_decision
import nash


def single_men(school_group, t, w_emax, h_emax, w_s_emax, h_s_emax, adjust_bp, verbose):
  if verbose:
    print("====================== single men: ", school_group, ",  ======================")
  
  base_husband = draw_husband.Husband()              # create a husband structure (and draw ability, in backward we redefine the ability in the loop
  draw_husband.update_school_and_age(school_group, t, base_husband)     # update his schooling according to his school_group
  iter_count = 0
  for ability_i in range(1, 4):                           # doe each ability level - open loop of ability
    base_husband.ability_hi = ability_i
    base_husband.ability_h_value = c.normal_arr[ability_i] * p.sigma3      # husband ability - low, medium, high
    sum = 0.0
    if verbose:
      draw_husband.print_husband(base_husband)

    for draw in range(0, c.DRAW_B):
      husband = base_husband
      wage_h = calculate_wage.calculate_wage_h(husband, epsilon())
      # probabilty of meeting a potential wife
      p_wife = math.exp(p.p0_h+p.p1_h*(husband.AGE+t)+p.p2_h*(husband.AGE+t)**2)/(1.0+math.exp(p.p0_h+p.p1_h*(husband.AGE+t)+p.p2_h*(husband.AGE+t)**2))
      CHOOSE_WIFE = 0
      wage_w = 0.0
      wife = draw_wife.Wife()
      if draw_p() < p_wife:
        CHOOSE_WIFE = 1
        wife = draw_wife.draw_wife(t, husband.age_index, school_group)
        draw_wife.update_wife_schooling(t, wife)
        wage_w = calculate_wage.calculate_wage_w(wife, draw_p(), epsilon())

      bp = c.INITIAL_BP
      is_single_men = True
      utility = calculate_utility.calculate_utility(w_emax, h_emax, w_s_emax, h_s_emax, c.NO_KIDS, wage_h, wage_w, CHOOSE_WIFE, c.UNMARRIED, wife, husband, t, bp, is_single_men)
      if CHOOSE_WIFE == 1:
        bp = nash.nash(utility)    # Nash bargaining at first period of marriage
      else:
        bp = c.NO_BP

      if verbose and CHOOSE_WIFE:
        draw_wife.print_wife(wife)

      if bp != c.NO_BP:
        # marriage decision
        decision = marriage_emp_decision.marriage_emp_decision(utility, bp, wife, husband, adjust_bp)
        if decision.M == c.MARRIED:
          sum += utility.U_H[decision.max_weighted_utility_index]
          if verbose:
            print("got married")
        else:
          sum += decision.outside_option_h_v
          assert(decision.outside_option_h_v == utility.U_H_S)
          if verbose:
            print("did not get married")
      else:
        sum += utility.U_H_S
        if verbose:
          print("did not get marriage offer")
      if verbose:
        print("====================== new draw ======================")

    h_s_emax[t][ability_i][school_group] = sum/c.DRAW_B
    if verbose:
      print("emax(", t, ", ", ability_i, ", ", school_group, ")=", sum/c.DRAW_B)
      print("======================================================")
    iter_count = iter_count + 1
  return iter_count
