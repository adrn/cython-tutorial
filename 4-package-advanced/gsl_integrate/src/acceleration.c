#include <gsl/gsl_errno.h>
#include <math.h>
#include "acceleration.h"

int func(double t, const double y[], double f[], void *params) {
    /*
        y[0], y[1], y[2] are x, y, z
        y[3], y[4], y[5] are v_x, v_y, v_z
    */

    (void)(t); /* avoid unused parameter warning */
    struct HernquistParams pars = *(struct HernquistParams *)params;

    double r;
    double dPhi_dr;

    r = sqrt(y[0]*y[0] + y[1]*y[1] + y[2]*y[2]);
    dPhi_dr = pars.G * pars.m / pow(r + pars.c, 2);

    // Derivative of position is just velocity
    f[0] = y[3];
    f[1] = y[4];
    f[2] = y[5];

    // Derivative of velocity is acceleration from potential
    f[3] = -dPhi_dr * y[0] / r;
    f[4] = -dPhi_dr * y[1] / r;
    f[5] = -dPhi_dr * y[2] / r;

    return GSL_SUCCESS;
}
