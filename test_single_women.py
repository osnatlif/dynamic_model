from unittest import TestCase

import numpy as np
import constant_parameters as c
import single_women


class TestSingleWomen(TestCase):
    def test_single_women(self):
        school_group = 1
        t = 1
        w_emax = np.ndarray([c.T_MAX, c.EXP_SIZE, c.KIDS_SIZE, c.WORK_SIZE, c.ABILITY_SIZE, c.ABILITY_SIZE, c.SCHOOL_SIZE, c.SCHOOL_SIZE, c.MATCH_Q_SIZE, c.BP_SIZE])
        h_emax = np.ndarray([c.T_MAX, c.EXP_SIZE, c.KIDS_SIZE, c.WORK_SIZE, c.ABILITY_SIZE, c.ABILITY_SIZE, c.SCHOOL_SIZE, c.SCHOOL_SIZE, c.MATCH_Q_SIZE, c.BP_SIZE])
        w_s_emax = np.ndarray([c.T_MAX, c.EXP_SIZE, c.KIDS_SIZE, c.WORK_SIZE, c.ABILITY_SIZE, c.SCHOOL_SIZE])
        h_s_emax = np.ndarray([c.T_MAX, c.ABILITY_SIZE, c.SCHOOL_SIZE])
        adjust_bp = True
        verbose = False
        iter_count = single_women.single_women(school_group, t, w_emax, h_emax, w_s_emax, h_s_emax, adjust_bp, verbose)
        print(iter_count)
