from time import perf_counter
from unittest import TestCase
import numpy as np

import draw_husband
import draw_wife
from random_pool import epsilon
import calculate_wage


class TestCalculateWage(TestCase):
    def test_calculate_wage_h(self):
        husband = draw_husband.Husband()
        result = calculate_wage.calculate_wage_h(husband, epsilon())
        print(result)

    def test_calculate_wage_w(self):
        wife = draw_wife.Wife()
        w_draw = 0.5
        result = calculate_wage.calculate_wage_w(wife, w_draw, epsilon())
        print(result)
    
    def test_calculate_wage_perf(self):
        iter_count = 10000
        times = []
        for i in range(iter_count):
            wife = draw_wife.Wife()
            w_draw = 0.5
            tic = perf_counter()
            result = calculate_wage.calculate_wage_w(wife, w_draw, epsilon())
            toc = perf_counter()
            times.append(toc - tic)

        print("%.4f %c %.4f (msec)" % (1000*np.mean(times),  chr(177), 1000*np.std(times)))
