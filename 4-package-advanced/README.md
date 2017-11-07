Building Cython files with external C dependencies
==================================================

One of the nice things about Cython is that is provides a way to interface with
external C code, either libraries or custom C files. As an example of this,
we're going to now integrate the same orbit in the same Hernquist potential as
before, but now we're going to use an 8th-order Runge-Kutta integration scheme
implemented in the GNU Scientific Library (GSL). If you don't have GSL
installed, you can install it using anaconda with:

```
conda install -c asmeurer gsl==1.16
```

You'll see that when interfacing with C code, the Cython code has to end up
looking a lot more like pure-C. In this case, it means using types and structs
defined within the GSL, and passing objects by reference to C functions. We also
have to add some complexity to the build process so that Cython can find the
necessary GSL files.

Since we're using an integrator implemented in GSL (i.e. in pure-C), we're also
going to re-write our acceleration function in C in a standalone file
`acceleration.c`. This isn't strictly necessary; it is possible to share
functions defined in Cython with C code. However, I've found that is does make
the build process a little easier to set up.

Let's start by taking a look at that code. In order to use the GSL ODE
integrators, we have to define a function that computes the derivatives of the
variables we are solving for. The variables of interest here are x, y, z, vx,
vy, vz. The derivative of x, y, z is just vx, vy, vz. The derivative of the
velocity terms are the acceleration terms, as we computed before using the
Hernquist potential. So, the main difference with the new acceleration function
is that we have to return the time-derivatives of all 6 phase-space coordinates,
rather than just the accelerations.

We now have to build our Cython file with this C acceleration file. To do that,
we have to add the C file as another "source" in the Cython `Extension`. Open
the `setup.py` file and let's look at the changes relative to that in
`3-package`.

*Note: see also [CythonGSL](https://github.com/twiecki/CythonGSL) which makes
interfacing with GSL from Cython code much simpler.*
