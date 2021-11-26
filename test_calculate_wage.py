import draw_husband
import draw_wife
import calculate_wage

def test():
    t = 1
    W = draw_wife.draw_wife(t, 0, 0)
    H = draw_husband.draw_husband(t, W)

    eps = 0.01
    draw = 0.1

    x = calculate_wage.calculate_wage_h(H, eps)
    print(x)
    y = calculate_wage.calculate_wage_w(W, draw, eps)
    print(y)
