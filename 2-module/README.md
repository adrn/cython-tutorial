Manually converting Cython files and compiling
==============================================

If we write a standalone Cython script, we have to first convert it to C using
the `cython` command-line tool, and then compile the C code into a shared
object. The command-line tool supports the annotate feature, just like the
IPython magic command via the flag `-a`. To generate a C file from this Cython
code with an annotation page, execute:

```bash
% cython -a leapfrog.pyx
```

You should now see 2 new files in this directory: `leapfrog.c` and
`leapfrog.html`. The `leapfrog.html` file shows the annotate Cython code,
similar to what we saw in the notebook (yellow lines indicate interaction with
the Python layer). Let's open this up and confirm that the code is still
C-optimized where it needs to be.

The `leapfrog.c` file is the C code generated from the Cython module. Let's open
this and see what's generated. There's a lot of stuff that looks like `PyObject`
or `__Pyx_...`. These are from the Python C interface and Cython C interface,
respectively. This file is now un-compiled C code, so to use it from Python we
have to compile it into a shared object file. To do this, you have to have a C
compiler installed (you probably all have this?), for example, `gcc` or `clang`.

On a Mac, with the xcode command line tools installed, you likely have `clang`
but can use it with a `gcc` frontend (i.e. you can type `gcc ... file.c`). Let's
now compile the `leapfrog.c` file. This will depend on your system and Python
installation, but it will be something like this, which is what works on my Mac
with an Anaconda Python 3.5 install in my home directory:

```bash
% gcc -fwrapv -O2 -Wall --std=gnu99 -Wp,-w -Wno-unused-function \
    -arch x86_64 -I/Users/adrian/anaconda/include/ \
    -arch x86_64 -I/Users/adrian/anaconda/lib/python3.5/site-packages/numpy/core/include \
    -I/Users/adrian/anaconda/include/python3.5m/ \
    -o leapfrog.o -c leapfrog.c
% gcc -shared -undefined dynamic_lookup -o leapfrog.so leapfrog.o
```

Hint: to find your numpy include path, start a Python shell and do:

```bash
% python
>>> import numpy
>>> numpy.get_include()
'/Users/adrian/anaconda/lib/python3.5/site-packages/numpy/core/include'
```

Now you should be able to import the `leapfrog` as a module. Let's try this from
the Python shell:

```bash
% python
>>> from leapfrog import leapfrog_integrate
```

Good! Now let's try running the `my_analysis.py` script and make sure the
function works.

Now we have an idea of how to compile Cython code, but this is cumbersome, and
does not scale well when you have multiple Cython modules. It's also not the
recommended way of building Cython code - a better way to do it is to use the
Python packaging tools through `distutils`. We'll see how to do that in the next
example.
