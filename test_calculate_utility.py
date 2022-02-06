from unittest import TestCase
import numpy as np

import constant_parameters as c
import draw_husband
import draw_wife
import calculate_utility

def draw_random_utility():
    t = 1
    age_index = 1
    HS = 1
    forward = False
    wife = draw_wife.draw_wife(t, age_index, HS)
    draw_wife.update_wife_schooling(wife.WS, t, wife)
    husband = draw_husband.draw_husband(t, wife, forward)
    kids = 1
    wage_h = 10000
    wage_w = 10000
    choose_partner = True
    M = True
    BP = 0.5
    single_men = False
    w_emax = np.ndarray([c.T_MAX, c.EXP_SIZE, c.KIDS_SIZE, c.ABILITY_SIZE, c.ABILITY_SIZE, c.SCHOOL_SIZE, c.SCHOOL_SIZE, c.MATCH_Q_SIZE, c.BP_SIZE])
    h_emax = np.ndarray([c.T_MAX, c.EXP_SIZE, c.KIDS_SIZE, c.ABILITY_SIZE, c.ABILITY_SIZE, c.SCHOOL_SIZE, c.SCHOOL_SIZE, c.MATCH_Q_SIZE, c.BP_SIZE])
    w_s_emax = np.ndarray([c.T_MAX, c.EXP_SIZE, c.KIDS_SIZE, c.WORK_SIZE, c.ABILITY_SIZE, c.SCHOOL_SIZE])
    h_s_emax = np.ndarray([c.T_MAX, c.ABILITY_SIZE, c.SCHOOL_SIZE])
    return wife, husband, calculate_utility.calculate_utility(w_emax, h_emax, w_s_emax, h_s_emax, kids, wage_h, wage_w, choose_partner, M, wife, husband, t, BP, single_men)

class TestCalculateUtility(TestCase):
    def test_calculate_utility(self):
        _, _, result = draw_random_utility()
        print(result)
