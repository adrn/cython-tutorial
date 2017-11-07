from distutils.core import setup
import numpy as np

from distutils.extension import Extension
from Cython.Build import cythonize

# We only have one extension for now:
extensions = [
    Extension("leapfrog_orbit.leapfrog",
              ["leapfrog_orbit/leapfrog.pyx"],
              include_dirs=[np.get_include()])
]

setup(
    name="leapfrog_orbit",
    ext_modules=cythonize(extensions)
)
