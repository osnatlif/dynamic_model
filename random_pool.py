import random
import numpy as np
# seed values: (BOOST_PP_COUNTER) should be incremented for each new function
# new functions should be added at the end of the file, to keep the previouse ones consistent between runs
# each distribution is using a mersenne_twister_engine seeded constant and different value

def epsilon():
#  static std::mt19937 gen(BOOST_PP_COUNTER)
#  static std::normal_distribution<> dis(0, 1)
  random.seed(1)
  gen = np.random.normal(0,1)
  return gen

def draw_3():
#  static std::mt19937 gen(BOOST_PP_COUNTER)
#  static std::uniform_int_distribution<> dis(0, 2)
  random.seed(1)
  gen = random.uniform(0, 1)
  return gen


def draw_p():
#   static std::mt19937 gen(BOOST_PP_COUNTER)
# static std::uniform_real_distribution<> dis(0.0, 1.0)
  random.seed(1)
  gen = random.uniform(0, 1)
  return gen

