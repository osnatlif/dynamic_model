from unittest import TestCase

import marriage_emp_decision
from test_calculate_utility import draw_random_utility


class TestMarriageEmpDecision(TestCase):
    def test_marriage_emp_decision(self):
        wife, husband, utility = draw_random_utility()
        BP = 0.5
        adjust_bp = True
        result = marriage_emp_decision.marriage_emp_decision(utility, BP, wife, husband, adjust_bp)
        print(result)
