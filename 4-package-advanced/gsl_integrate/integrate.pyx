# cython: boundscheck=False, wraparound=False, nonecheck=False, cdivision=True

import numpy as np # access to Numpy from Python layer
cimport numpy as np # access to Numpy from Cython layer
np.import_array()

# ----------------------------------------------------------------------------
# C definitions

cdef extern from "gsl/gsl_errno.h":
    enum: GSL_SUCCESS

cdef extern from "gsl/gsl_odeiv2.h":
    ctypedef struct gsl_odeiv2_system:
        int (*function) (double t, const double y[], double dydt[], void *params);
        int (*jacobian) (double t, const double y[], double *dfdy, double dfdt[],
                         void *params);
        size_t dimension;
        void *params;

    ctypedef struct gsl_odeiv2_driver

    ctypedef struct gsl_odeiv2_step_type
    gsl_odeiv2_step_type *gsl_odeiv2_step_rk8pd

    gsl_odeiv2_driver *gsl_odeiv2_driver_alloc_y_new(
        gsl_odeiv2_system *sys, gsl_odeiv2_step_type *T,
        double hstart, double epsabs, double epsrel) nogil

    int gsl_odeiv2_driver_apply(gsl_odeiv2_driver *d,
        double *t, double t1, double y[]) nogil

    int gsl_odeiv2_driver_free(gsl_odeiv2_driver *d) nogil

cdef extern from "src/acceleration.h":
    cdef struct HernquistParams:
        double G
        double m
        double c

    int func (double t, const double y[], double f[], void *params) nogil

# ----------------------------------------------------------------------------
# Now the actual Cython code!

cdef _integrate(double[::1] y0, double dt, int n_steps, dict params):
    cdef:
        # Create arrays to store positions and velocities at all times
        double[:,::1] y = np.zeros((n_steps+1, 6), np.float64)
        double[::1] t = np.zeros(n_steps+1, np.float64)

        # Explicitly type the iteration variable
        int i, k

        # dimensionality is 2 * 3D
        int dim = 6
        double ti

        HernquistParams pars
        gsl_odeiv2_system sys
        gsl_odeiv2_driver *d
        int status

    pars.G = params['G']
    pars.m = params['m']
    pars.c = params['c']

    sys.function = func
    sys.jacobian = NULL
    sys.dimension = dim
    sys.params = &pars

    d = gsl_odeiv2_driver_alloc_y_new(&sys, gsl_odeiv2_step_rk8pd,
                                      1e-6, 1e-6, 0.0);

    # store initial conditions
    for k in range(6):
        y[0,k] = y0[k]
    t[0] = 0.
    ti = t[0]

    for i in range(1, n_steps+1):
        for k in range(6):
            y[i,k] = y[i-1,k]

        status = gsl_odeiv2_driver_apply(d, &ti, ti+dt, &y[i,0]);
        t[i] = ti

        if status != GSL_SUCCESS:
            raise RuntimeError("Integration error. GSL return value = {0}"
                               .format(status))

    gsl_odeiv2_driver_free(d)

    return t, y

cpdef integrate(x0, v0, dt, n_steps, hernquist_args=()):
    cdef:
        # define memoryview's for initial conditions
        double[::1] y0 = np.concatenate((np.array(x0, np.float64),
                                         np.array(v0, np.float64)))

        double _dt = dt
        int _nsteps = n_steps

    params = dict()
    params['G'] = hernquist_args[0]
    params['m'] = hernquist_args[1]
    params['c'] = hernquist_args[2]

    t, y = _integrate(y0, _dt, _nsteps, params)

    return np.array(t), np.array(y[:,:3]), np.array(y[:,3:])
