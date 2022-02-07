from unittest import TestCase

import nash
from test_calculate_utility import draw_random_utility


class TestNash(TestCase):
    def test_nash(self):
        _, _, utility = draw_random_utility()
        result = nash.nash(utility)
        print(result)
