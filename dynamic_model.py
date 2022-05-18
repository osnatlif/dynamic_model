# entry point for the dynamic model estimation
from time import perf_counter
import getopt
import sys
import calculate_emax as ce
import forward_simulation as fs


def usage(proc):
    print("usage: " + proc +
          "\n\t-s --static: do not calculate emax" +
          "\n\t-m --moments: display moments" +
          "\n\t-v --verbose" +
          "\n\t-a --adjust-bp")
    exit(0)


def main():
    options = "hsvma"
    long_options = ["help", "static", "verbose", "moments", "adjust-bp"]
    display_moments = False
    verbose = False
    static_model = False
    adjust_bp = False
    try:
        args, values = getopt.getopt(sys.argv[1:], options, long_options)
        for arg, val in args:
            if arg in ("-h", "--Help"):
                usage(sys.argv[0])
            elif arg in ("-m", "--moments"):
                display_moments = True
            elif arg in ("-v", "--verbose"):
                verbose = True
            elif arg in ("-s", "--static"):
                static_model = True
            elif arg in ("-a", "--adjust-bp"):
                adjust_bp = True
    except getopt.error as err:
        # output error, and return with an error code
        print(str(err))
        usage(sys.argv[0])

    w_emax = ce.create_married_emax()
    h_emax = ce.create_married_emax()
    w_s_emax = ce.create_single_w_emax()
    h_s_emax = ce.create_single_h_emax()
    if not static_model:
        tic = perf_counter()
        iter_count = ce.calculate_emax(w_emax, h_emax, w_s_emax, h_s_emax, adjust_bp, verbose)
        toc = perf_counter()
        print("calculate emax with %d iterations took: %.4f (sec)" % (iter_count, (toc - tic)))
    else:
        print("static model, emax not calculated")

    value = fs.forward_simulation(w_emax, h_emax, w_s_emax, h_s_emax, adjust_bp, verbose, display_moments)
    print(value)



if __name__ == "__main__":
    main()
