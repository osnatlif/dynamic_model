from time import perf_counter
from unittest import TestCase

import numpy as np
import constant_parameters as c
import married_couple
import married_couple_cy


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
        iter_count = married_couple.married_couple(school_group, t, w_emax, h_emax, w_s_emax, h_s_emax, adjust_bp, verbose)
        print(iter_count)
    
    def test_married_couple_perf(self):
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
            married_couple.married_couple(school_group, t, w_emax, h_emax, w_s_emax, h_s_emax, adjust_bp, verbose)
            toc = perf_counter()
            times.append(toc - tic)

        print("%.4f %c %.4f (msec)" % (1000*np.mean(times),  chr(177), 1000*np.std(times)))

    def test_married_couple_cy_perf(self):
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
            married_couple_cy.married_couple_cy(school_group, t, w_emax, h_emax, w_s_emax, h_s_emax, adjust_bp, verbose)
            toc = perf_counter()
            times.append(toc - tic)

        print("%.4f %c %.4f (msec)" % (1000*np.mean(times),  chr(177), 1000*np.std(times)))

