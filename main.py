import numpy as np

import constant_parameters as c
import parameters as p
import draw_husband
import draw_wife
# print(p.alpha)
import numpy as np

# husbands = np.loadtxt("husbands.out")
# print(husbands)
#vded_and_ex = np.loadtxt("deductions_exemptions.out")
# print(ded_and_ex)
temp = np.ones(c.CS_SIZE)
print(temp)
weighted_utility_both = temp * c.MINIMUM_UTILITY
print(weighted_utility_both)

H = draw_husband.Husband()
W = draw_wife.Wife()
draw_husband.update_school_age_exp(H,W)
draw_husband.print_husband(H)
import math
import calculate_wage
from gross_to_net import gross_to_net
# calculate_wage_h(H_HSD, H_HSG, H_SC, H_CG, H_PC, HE, epsilon, ability_h):
x = calculate_wage.calculate_wage_h( 1, 0, 0, 0, 0, 10, 0.3, 0.22)
print(x)
#calculate_wage_w(HSD, HSG, SC, CG, PC, WE, epsilon, prev_state_w, w_draw, ability_w):
y = calculate_wage.calculate_wage_w( 0, 1, 0, 0, 0, 10, 0.3,1,0.2, 0.22)
print(y)
# gross_to_net(kids, wage_w, wage_h, t, age_index)
net_m= gross_to_net(1, y, x, 10, 1)
print(net_m.net_income_m)
print(net_m.net_income_s_h)
print(net_m.net_income_s_w)
print(net_m.net_income_m_unemp)

def print_hi(name, age):
    array = [1, 5, 7, 88]
    print(array)
    # Use a breakpoint in the code line below to debug your script.
    #for i in range(7,10):
    for i in array:
        if i%2 == 0:
            print('Hi, ' + name + ' ', i)
    return age**2

#print("hello")

#print(print_hi("yuval", 44))
