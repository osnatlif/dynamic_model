import calculate_utility
import constant_parameters as c
import numpy as np
import draw_wife
import draw_husband

def test():
    w_emax = np.zeros(
        [c.T_MAX,
        c.EXP_SIZE,
        len(c.KIDS_VALUES),
        len({c.EMP, c.UNEMP}),
        len(c.ABILITY_VALUES),
        len(c.ABILITY_VALUES),
        len(c.SCHOOL_W_VALUES),
        len(c.SCHOOL_W_VALUES),
        len(c.MATCH_Q_VALUES),
        len(c.BP_W_VALUES)]
    )

    h_emax = np.zeros(
        [c.T_MAX,
        c.EXP_SIZE,
        len(c.KIDS_VALUES),
        len({c.EMP, c.UNEMP}),
        len(c.ABILITY_VALUES),
        len(c.ABILITY_VALUES),
        len(c.SCHOOL_W_VALUES),
        len(c.SCHOOL_W_VALUES),
        len(c.MATCH_Q_VALUES),
        len(c.BP_W_VALUES)]
    )

    w_s_emax = np.zeros(
        [c.T_MAX,
        c.EXP_SIZE,
        len(c.KIDS_VALUES),
        len({c.EMP, c.UNEMP}),
        len(c.ABILITY_VALUES),
        len(c.SCHOOL_W_VALUES)]
    )

    h_s_emax = np.zeros(
        [c.T_MAX,
        len(c.ABILITY_VALUES),
        len(c.SCHOOL_W_VALUES)]
    )

    kids = 1
    wage_h = 10000
    wage_w = 5000
    choose_partner = True
    M = True
    t = 1
    wife = draw_wife.draw_wife(t, 1, 1)
    draw_wife.update_wife_schooling(t, wife)
    draw_wife.print_wife(wife)
    husband = draw_husband.draw_husband(t, wife)
    draw_husband.print_husband(husband)
    BP = 0.5
    single_men = False

    u = calculate_utility.calculate_utility(w_emax, h_emax, w_s_emax, h_s_emax, kids, wage_h, wage_w, choose_partner, M, wife, husband, t, BP, single_men)
    print(u.wife)
    print(u.husband)
    print(u.wife_s)
    print(u.husband_s)
