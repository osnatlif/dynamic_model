from unittest import TestCase
import numpy as np

import draw_husband
import draw_wife
import marriage_emp_decision
import calculate_utility
import constant_parameters as c


class TestMarriageEmpDecision(TestCase):
    def test_marriage_emp_decision(self):
        t = 1
        age_index = 1
        HS = 1
        forward = False
        wife = draw_wife.draw_wife(t, age_index, HS)
        draw_wife.update_wife_schooling(t, wife)
        husband = draw_husband.draw_husband(t, wife, forward)
        kids = 1
        wage_h = 10000
        wage_w = 10000
        choose_partner = True
        M = True
        BP = 0.5
        single_men = False
        w_emax = np.ndarray(
            [c.T_MAX, c.EXP_SIZE, c.KIDS_SIZE, c.ABILITY_SIZE, c.ABILITY_SIZE, c.SCHOOL_SIZE, c.SCHOOL_SIZE,
             c.MATCH_Q_SIZE, c.BP_SIZE])
        h_emax = np.ndarray(
            [c.T_MAX, c.EXP_SIZE, c.KIDS_SIZE, c.ABILITY_SIZE, c.ABILITY_SIZE, c.SCHOOL_SIZE, c.SCHOOL_SIZE,
             c.MATCH_Q_SIZE, c.BP_SIZE])
        w_s_emax = np.ndarray([c.T_MAX, c.EXP_SIZE, c.KIDS_SIZE, c.WORK_SIZE, c.ABILITY_SIZE, c.SCHOOL_SIZE])
        h_s_emax = np.ndarray([c.T_MAX, c.SCHOOL_SIZE])
        utility = calculate_utility.calculate_utility(w_emax, h_emax, w_s_emax, h_s_emax, kids, wage_h, wage_w,
                                                     choose_partner, M, wife, husband, t, BP, single_men)
        adjust_bp = True
        result = marriage_emp_decision.marriage_emp_decision(utility, BP, wife, husband, adjust_bp)
        print(result)
