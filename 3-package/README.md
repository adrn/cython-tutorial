Building Cython files as a part of a package build
==================================================

Cython provides a nice way to compile Cython code during the build process of a
Python package. To use this, we have to write a `setup.py` file that uses the
Python `distutils` to "cythonize" any Cython code in our package. In this case,
we only have one Cython module to build, but we'll write the setup code so that
it's easy to see how you would add more.

To actually build the package, we can either install it into our Python site
packages using `python setup.py install`, or just build the code in place. The
former is useful if you're developing a larger package (see also `python
setup.py develop`), the latter is more useful for standalone scripts that have
Cython code dependencies.

For now, we're going to just build the code in place. We do that with:

```bash
python setup.py build_ext --inplace
```

You'll see this basically does that we did in the manual step: converts Cython
to C, compiles an object file, then builds a shared library file.

We can now run the `my_analysis.py` script as we did before and import the built
code.
