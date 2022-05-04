from time import perf_counter
from unittest import TestCase

import numpy as np
import constant_parameters as c
from objective_function import calculate_emax


class TestCalculateEmax(TestCase):
    def test_calculate_emax(self):
        w_emax = np.ndarray([c.T_MAX, c.EXP_SIZE, c.KIDS_SIZE, c.WORK_SIZE, c.ABILITY_SIZE, c.ABILITY_SIZE, c.SCHOOL_SIZE, c.SCHOOL_SIZE, c.MATCH_Q_SIZE, c.BP_SIZE])
        h_emax = np.ndarray([c.T_MAX, c.EXP_SIZE, c.KIDS_SIZE, c.WORK_SIZE, c.ABILITY_SIZE, c.ABILITY_SIZE, c.SCHOOL_SIZE, c.SCHOOL_SIZE, c.MATCH_Q_SIZE, c.BP_SIZE])
        w_s_emax = np.ndarray([c.T_MAX, c.EXP_SIZE, c.KIDS_SIZE, c.WORK_SIZE, c.ABILITY_SIZE, c.SCHOOL_SIZE])
        h_s_emax = np.ndarray([c.T_MAX, c.ABILITY_SIZE, c.SCHOOL_SIZE])
        adjust_bp = False
        verbose = False
        tic = perf_counter()
        iter_count = calculate_emax(w_emax, h_emax, w_s_emax, h_s_emax, adjust_bp, verbose)
        toc = perf_counter()
        print("calculate emax with %d iterations took: %.4f (sec)" % (iter_count, (toc - tic)))
