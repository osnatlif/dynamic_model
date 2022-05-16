# to build the cython extensions use: python setup.py build_ext --inplace

from setuptools import setup, Extension
from Cython.Build import cythonize

from Cython.Compiler import Options
Options.buffer_max_dims = 11

extensions = [
        Extension("moments", ["moments.pyx"]),
        Extension("forward_simulation", ["forward_simulation.pyx"]),
        Extension("single_men", ["single_men.pyx"]),
        Extension("single_women", ["single_women.pyx"]),
        Extension("married_couple", ["married_couple.pyx"]),
        Extension("test_married_couple", ["test_married_couple.pyx"]),
        Extension("calculate_emax", ["calculate_emax.pyx"]),
        Extension("test_calculate_emax", ["test_calculate_emax.pyx"]),
        Extension("calculate_utility", ["calculate_utility.pyx"]),
        Extension("calculate_wage", ["calculate_wage.pyx"]),
        Extension("parameters", ["parameters.pyx"]),
        Extension("constant_parameters", ["constant_parameters.pyx"]),
        Extension("draw_husband", ["draw_husband.pyx"]),
        Extension("draw_wife", ["draw_wife.pyx"]),
        Extension("nash", ["nash.pyx"]),
        Extension("gross_to_net", ["gross_to_net.pyx"]),
        Extension("value_to_index", ["value_to_index.pyx"]),
        Extension("marriage_emp_decision", ["marriage_emp_decision.pyx"])
]

setup(ext_modules=cythonize(extensions, language_level="3"))
