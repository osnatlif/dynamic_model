import random
import numpy as np


def epsilon():
  gen = np.random.normal(0, 1)
  return gen


def draw_3():
  gen = random.randint(0, 2)
  return gen


def draw_p():
  gen = random.uniform(0, 1)
  return gen

