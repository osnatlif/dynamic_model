from time import perf_counter
from unittest import TestCase
import numpy as np
cimport constant_parameters as c
from married_couple cimport married_couple


class TestMarriedCouple(TestCase):
    def test_married_couple(self):
        school_group = 1
        t = 1
        w_emax = np.ndarray([c.T_MAX, c.EXP_SIZE, c.KIDS_SIZE, c.WORK_SIZE, c.ABILITY_SIZE, c.ABILITY_SIZE, c.SCHOOL_SIZE, c.SCHOOL_SIZE, c.MATCH_Q_SIZE, c.BP_SIZE])
        h_emax = np.ndarray([c.T_MAX, c.EXP_SIZE, c.KIDS_SIZE, c.WORK_SIZE, c.ABILITY_SIZE, c.ABILITY_SIZE, c.SCHOOL_SIZE, c.SCHOOL_SIZE, c.MATCH_Q_SIZE, c.BP_SIZE])
        w_s_emax = np.ndarray([c.T_MAX, c.EXP_SIZE, c.KIDS_SIZE, c.WORK_SIZE, c.ABILITY_SIZE, c.SCHOOL_SIZE])
        h_s_emax = np.ndarray([c.T_MAX, c.ABILITY_SIZE, c.SCHOOL_SIZE])
        adjust_bp = False
        verbose = False
        iter_count = 5
        times = []
        for i in range(iter_count):
            tic = perf_counter()
            married_couple(school_group, t, w_emax, h_emax, w_s_emax, h_s_emax, adjust_bp, verbose)
            toc = perf_counter()
            times.append(toc - tic)

        print("%.4f %c %.4f (msec)" % (1000*np.mean(times),  chr(177), 1000*np.std(times)))

