from distutils.core import setup, Extension
from Cython.Build import cythonize

from Cython.Compiler import Options
Options.buffer_max_dims = 11

extensions = [
        Extension("married_couple_cy", ["married_couple_cy.pyx"]),
        Extension("calculate_utility_cy", ["calculate_utility_cy.pyx"])
]
#define_macros=[('NPY_NO_DEPRECATED_API', 'NPY_1_7_API_VERSION')]

setup(ext_modules=cythonize(extensions, language_level = "3"))

