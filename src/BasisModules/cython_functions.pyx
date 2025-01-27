#!python
#cython: language_level=3

# run with python3 setup.py build_ext --inplace

from libc.math cimport sin, cos, fabs
cimport cython
from cython.parallel cimport prange

import numpy as np
cimport scipy.special.cython_special as csc

#cdef int n_threads = 12

@cython.boundscheck(False)
@cython.wraparound(False)
cdef void _parallel_G(double k, double[:,:] x, double[:,:] y,
                      double complex[:,:] out) nogil:
    cdef int i, j

    for i in prange(x.shape[0], num_threads = None):
        for j in range(y.shape[0]):
            out[i,j] = 0.25j*csc.hankel1(0, k*fabs(x[i,j] - y[i,j]))

def parallel_G(k, x, y):
    out = np.empty_like(x, dtype='complex128')
    _parallel_G(k, x, y, out)
    return out



#pralellized bessel function

@cython.boundscheck(False)
@cython.wraparound(False)
cdef void bessel_parallel(double order, double[:] arg,
                          double[:] out) nogil:
    cdef int i
    for i in prange(arg.shape[0], num_threads = None):
        out[i] = csc.jv(order, arg[i])

@cython.boundscheck(False)
@cython.wraparound(False)
cdef void bessel_parallel32(float order, float[:] arg,
                          float[:] out) nogil:
    cdef int i
    for i in prange(arg.shape[0], num_threads = None):
        out[i] = csc.jv(order, arg[i])

def Jv(order, arg):
    sh = arg.shape
    d = len(sh)
    dtyp = arg.dtype
    if d ==1:
        out = np.empty_like(arg, dtype=dtyp )
        if dtyp == 'double':
            bessel_parallel(order, arg, out)
        else:
            bessel_parallel32(order, arg, out)
    if d == 2:
        arg = np.ravel(arg)
        out = np.empty_like(arg, dtype=dtyp )
        if dtyp == 'double':
            bessel_parallel(order, arg, out)
        else:
            bessel_parallel32(order, arg, out)
        out.reshape(sh)
    return out 

#pralellized bessel derivative function

@cython.boundscheck(False)
@cython.wraparound(False)
cdef void bessel_derivative_parallel(double order, double[:] arg,
                          double[:] out) nogil:
    cdef int i
    for i in prange(arg.shape[0], num_threads = None):
        out[i] = 0.5*(csc.jv(order-1, arg[i])-csc.jv(order+1, arg[i]))

@cython.boundscheck(False)
@cython.wraparound(False)
cdef void bessel_derivative_parallel32(float order, float[:] arg,
                          float[:] out) nogil:
    cdef int i
    for i in prange(arg.shape[0], num_threads = None):
        out[i] = 0.5*(csc.jv(order-1, arg[i])-csc.jv(order+1, arg[i]))



def Jvp(order, arg):
    sh = arg.shape
    d = len(sh)
    dtyp = arg.dtype
    if d ==1:
        out = np.empty_like(arg, dtype=dtyp)
        if dtyp == 'double':
            bessel_derivative_parallel(order, arg, out)
        else:
            bessel_derivative_parallel(order, arg, out)
    if d == 2:
        arg = np.ravel(arg)
        out = np.empty_like(arg, dtype=dtyp)
        if dtyp == 'double':
            bessel_derivative_parallel(order, arg, out)
        else:
            bessel_derivative_parallel(order, arg, out)
        out.reshape(sh)
    return out 

#pralellized sine function

@cython.boundscheck(False)
@cython.wraparound(False)
cdef void sin_parallel( double[:] arg,
                          double[:] out) nogil:
    cdef int i
    for i in prange(arg.shape[0], num_threads = None):
        out[i] = sin(arg[i])

@cython.boundscheck(False)
@cython.wraparound(False)
cdef void sin_parallel32( float[:] arg,
                          float[:] out) nogil:
    cdef int i
    for i in prange(arg.shape[0], num_threads = None):
        out[i] = sin(arg[i])

def Sin(arg):
    sh = arg.shape
    d = len(sh)
    dtyp = arg.dtype
    if d ==1:
        out = np.empty_like(arg, dtype=dtyp)
        if dtyp == 'double':
            sin_parallel( arg, out)
        else:
            sin_parallel32( arg, out)
        
    if d == 2:
        arg = np.ravel(arg)
        out = np.empty_like(arg, dtype=dtyp)
        if dtyp == 'double':
            sin_parallel( arg, out)
        else:
            sin_parallel32( arg, out)
        out.reshape(sh)
    return out 

@cython.boundscheck(False)
@cython.wraparound(False)
cdef void cos_parallel( double[:] arg,
                          double[:] out) nogil:
    cdef int i
    for i in prange(arg.shape[0], num_threads = None):
        out[i] = cos(arg[i])

@cython.boundscheck(False)
@cython.wraparound(False)
cdef void cos_parallel32( float[:] arg,
                          float[:] out) nogil:
    cdef int i
    for i in prange(arg.shape[0], num_threads = None):
        out[i] = cos(arg[i])

def Cos(arg):
    sh = arg.shape
    d = len(sh)
    dtyp = arg.dtype
    if d ==1:
        out = np.empty_like(arg, dtype=dtyp)
        if dtyp == 'double':
            cos_parallel( arg, out)
        else:
            cos_parallel32( arg, out)
    if d == 2:
        arg = np.ravel(arg)
        out = np.empty_like(arg, dtype=dtyp)
        if dtyp == 'double':
            cos_parallel( arg, out)
        else:
            cos_parallel32( arg, out)
        out.reshape(sh)
    return out 