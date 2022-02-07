from unittest import TestCase
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
