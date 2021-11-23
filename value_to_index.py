# convert values to indexes on their respective grids

def exp_to_index(exp):   # levels grid: 0, 1-2, 3-4, 5-10, 11+
  if exp == 0:
    return 0
  elif exp < 3:  # 1 or 2 years
    return 1
  elif exp < 6:  # 3 or 5 years
    return 2
  elif exp < 11:  # 6 to 10 years
    return 3
  else:    # above 11 years of experience
    return 4


def bp_to_index(bp):
  assert(bp >= 0 and bp <= 1)
  if bp < 0.2:
    return 0
  elif bp < 0.3:
    return 1
  elif bp < 0.4:
    return 2
  elif bp < 0.5:
    return 3
  elif bp < 0.6:
    return 4
  elif bp < 0.7:
    return 5
  elif bp < 0.8:
    return 6
  else:     # 0.8 <= bp <= 1
    return 7

