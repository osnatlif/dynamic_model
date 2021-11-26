import math
import parameters as p


def calculate_wage_h(husband, epsilon):
# this function calculates husbands actual wage
    tmp1 = (husband.ability_h_value + p.beta10_h*(husband.HE*husband.HSD) + p.beta11_h*(husband.HE*husband.HSG) + p.beta12_h*(husband.HE*husband.SC) + p.beta13_h*(husband.HE*husband.CG) + p.beta14_h*(husband.HE*husband.PC)
        + p.beta20_h*(husband.HE*husband.HSD)**2 + p.beta21_h*(husband.HE*husband.HSG)**2 + p.beta22_h*(husband.HE*husband.SC)**2 + p.beta23_h*(husband.HE*husband.CG)**2 + p.beta24_h*(husband.HE*husband.PC)**2
        + p.beta30_h*husband.HSD + p.beta31_h*husband.HSG + p.beta32_h*husband.SC + p.beta33_h*husband.CG + p.beta34_h*husband.PC)
    tmp2 = epsilon * p.sigma_h_wage
    wage = math.exp(tmp1 + tmp2)
    return wage


def calculate_wage_w(wife, w_draw, epsilon):
    # this function calculates wives actual wage
    prob_tmp = (p.row0_w*wife.emp_state + p.row11_w*wife.HSG + p.row12_w*wife.SC + p.row13_w*wife.CG + p.row14_w*wife.PC + p.row2_w*wife.WE)
    prob_w = math.exp(prob_tmp)/(1+math.exp(prob_tmp))
    # print(prob_w)
    if prob_w > w_draw:
        tmp1 = wife.ability_w_value + p.beta11_w * wife.WE * wife.HSG + p.beta12_w * wife.WE * wife.SC + p.beta13_w * wife.WE * wife.CG + p.beta14_w * wife.WE * wife.PC \
            + p.beta21_w * (wife.WE * wife.HSG)**2 + p.beta22_w * (wife.WE * wife.SC)**2 + p.beta23_w * (wife.WE * wife.CG)**2 + p.beta24_w * (wife.WE * wife.PC)**2 \
            + p.beta31_w * wife.HSG + p.beta32_w * wife.SC + p.beta33_w * wife.CG + p.beta34_w * wife.PC
        tmp2 = epsilon * p.sigma_w_wage
        wage = math.exp(tmp1 + tmp2)
        return wage
    else:
        # negative_infinity = float('-inf')
        wage = 0   # should be -inf?
        return wage