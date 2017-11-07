from distutils.core import setup
import numpy as np

from distutils.extension import Extension
from Cython.Build import cythonize

# We only have one extension for now:
extensions = [
    Extension("gsl_integrate.integrate",
              ["gsl_integrate/integrate.pyx",
               "gsl_integrate/src/acceleration.c"],
              include_dirs=[np.get_include(), 'gsl_integrate/src/'],
              libraries=['gsl', 'gslcblas'])
]

setup(
    name="gsl_integrate",
    ext_modules=cythonize(extensions),
    package_data={'gsl_integrate': ['src/*.h']}
)
