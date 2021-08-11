/*
  This file is part of Tencalc.

  Copyright (C) 2012-21 The Regents of the University of California
  (author: Dr. Joao Hespanha).  All rights reserved.
*/

#include "mex.h"
#include <stdint.h>
#ifdef DYNAMIC_LIBRARY
#ifdef __APPLE__
#define EXPORT __attribute__((visibility("default")))
#elif __linux__
#define EXPORT __attribute__((visibility("default")))
#elif _WIN32
#define EXPORT __declspec(dllexport)
#endif
#else
#define EXPORT 
#endif

EXPORT void plus(
   /* inputs */
   double *X1,
   double *X2,
   /* outputs */
   double *Y,
   /* sizes */
   mwSize m,
   mwSize n);

EXPORT void mtimes(
   /* inputs */
   double *X1,
   double *X2,
   /* outputs */
   double *Y,
   /* sizes */
   mwSize m,
   mwSize k,
   mwSize n);
