"""
Here we execute some analysis using orbits integrated in a Hernquist potential.
"""

# Third-party
from astropy.constants import G
import astropy.units as u
import matplotlib.pyplot as plt

# Project
from leapfrog_orbit import leapfrog_integrate

def main():
    # The unit system we'll use:
    units = [u.Myr, u.kpc, u.Msun]
    _G = G.decompose(units).value

    # Initial conditions
    x0 = [10., 0, 0]
    v0 = [0, 0.15, 0]

    # Parameters of the Hernquist potential model
    m = 1E11 # Msun
    c = 1. # kpc

    # Timestep in Myr
    dt = 1.
    n_steps = 10000 # 10 Gyr

    t, x, v = leapfrog_integrate(x0, v0, dt, n_steps,
                                 hernquist_args=(_G, m, c))

    # Plot the orbit
    fig, axes = plt.subplots(1, 2, figsize=(10,5))

    axes[0].plot(x[:,0], x[:,1], marker='.', linestyle='none', alpha=0.1)
    axes[0].set_xlim(-12, 12)
    axes[0].set_ylim(-12, 12)

    axes[0].set_xlabel('$x$')
    axes[0].set_ylabel('$y$')

    # ---

    axes[1].plot(v[:,0], v[:,1], marker='.', linestyle='none', alpha=0.1)
    axes[1].set_xlim(-0.35, 0.35)
    axes[1].set_ylim(-0.35, 0.35)

    axes[1].set_xlabel('$v_x$')
    axes[1].set_ylabel('$v_y$')

    fig.tight_layout()
    plt.show()

if __name__ == "__main__":
    main()
