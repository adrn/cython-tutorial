# cython: boundscheck=False, wraparound=False, nonecheck=False, cdivision=True

import numpy as np # access to Numpy from Python layer
cimport numpy as np # access to Numpy from Cython layer
np.import_array()

# this is like #include <math.h>, but defines the functions in Cython
from libc.math cimport sqrt

cimport cython

cdef void acc(double[::1] xyz, double G, double m, double a,
                  double[::1] a_xyz):
    cdef:
        double r
        double dPhi_dr

    r = sqrt(xyz[0]**2 + xyz[1]**2 + xyz[2]**2)
    dPhi_dr = G * m / (r + a)**2

    a_xyz[0] = -dPhi_dr * xyz[0] / r
    a_xyz[1] = -dPhi_dr * xyz[1] / r
    a_xyz[2] = -dPhi_dr * xyz[2] / r

cpdef leapfrog_integrate(x0, v0, double dt, int n_steps, hernquist_args=()):
    cdef:
        # define memoryview's for initial conditions
        double[::1] _x0 = np.array(x0, np.float64)
        double[::1] _v0 = np.array(v0, np.float64)

        # Create arrays to store positions and velocities at all times
        double[:,::1] x = np.zeros((n_steps+1, 3), np.float64) # 2d arrays - note the [:,::1]
        double[:,::1] v = np.zeros((n_steps+1, 3), np.float64)
        double[::1] t = np.zeros(n_steps+1, np.float64)

        # Explicitly type the iteration variable
        int i, k

        # placeholder for acceleration values
        double[::1] a_i = np.zeros(3)

        # placeholder for velocity incremented by 1/2 step
        double[::1] v_iminus1_2 = np.zeros(3)

        # explicitly typed and defined parameters
        double G = float(hernquist_args[0])
        double m = float(hernquist_args[1])
        double c = float(hernquist_args[2])

    # get the acceleration at the initial position
    acc(_x0, G, m, c, a_i)

    # if i is cython typed, this will be a much more efficient C loop
    for k in range(3):
        x[0,k] = _x0[k]
        v[0,k] = _v0[k]

        # Increment velocity by 1/2 step
        v_iminus1_2[k] = _v0[k] + dt/2. * a_i[k]

    for i in range(1, n_steps+1):
        for k in range(3):
            x[i,k] = x[i-1,k] + v_iminus1_2[k] * dt # full step

        acc(x[i], G, m, c, a_i)

        for k in range(3):
            v[i,k] = v_iminus1_2[k] + a_i[k] * dt/2. # half step
            v_iminus1_2[k] = v[i,k] + a_i[k] * dt/2. # another half step

        t[i] = t[i-1] + dt

    # convert from memoryview to array
    return np.array(t), np.array(x), np.array(v)
