/*
  Copyright 2012-2017 Joao Hespanha

  This file is part of Tencalc.

  TensCalc is free software: you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  TensCalc is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with TensCalc.  If not, see <http://www.gnu.org/licenses/>.
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
