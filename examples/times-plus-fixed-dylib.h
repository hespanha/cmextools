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
   const double *X1,
   const double *X2,
   /* outputs */
   double *Y);

EXPORT void mtimes(
   /* inputs */
   const double *X1,
   const double *X2,
   /* outputs */
   double *Y);
