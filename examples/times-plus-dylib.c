/*
  This file is part of Tencalc.

  Copyright (C) 2012-21 The Regents of the University of California
  (author: Dr. Joao Hespanha).  All rights reserved.
*/

#include <string.h> /* needed by memcpy */
#include <stdint.h> /* needed by uint64_t */
#include <inttypes.h> /* needed by PRId64 */
#include <stdio.h>  /* needed by printf */
#include <fcntl.h>  /* needed by open */
#include <float.h>  /* needed by DBL_MAX */
#include <math.h>   /* needed by fmin, fabs, etc. */
#include <time.h>   /* needed by clock() */

#include "times-plus-dylib.h"

#ifdef __APPLE__
#include <unistd.h> /* needed by open */
/* To get nano-sec time in OSX */
#include <mach/mach.h>        /* needed by OSX mach_absolute_time() */
#include <mach/mach_time.h>   /* needed by OSX mach_absolute_time() */

#define clock_t uint64_t
#define clock mach_absolute_time
#undef  CLOCKS_PER_SEC
#define CLOCKS_PER_SEC (uint64_t)1000000000
#elif __linux__
#include <unistd.h> /* needed by open */
#define clock_t uint64_t
#define clock clock_ns
#undef  CLOCKS_PER_SEC
#define CLOCKS_PER_SEC (uint64_t)1000000000
clock_t clock_ns() { struct timespec tp;  clock_gettime(CLOCK_REALTIME,&tp); return CLOCKS_PER_SEC*tp.tv_sec+tp.tv_nsec;}
#elif _WIN32
#include <Windows.h>
#include <tchar.h>
#include <stdio.h>
#include <stdint.h>
#define clock_t uint64_t
#define clock clock_ns
#undef  CLOCKS_PER_SEC
#define CLOCKS_PER_SEC (uint64_t)1000000000
clock_t clock_ns() {LARGE_INTEGER li; LARGE_INTEGER freq; QueryPerformanceCounter(&li); QueryPerformanceFrequency(&freq); return (li.QuadPart*CLOCKS_PER_SEC/freq.QuadPart);}
#endif
/* Status of the dependency groups */
int groupStatus[]={0,0,0,0,0,0,0,0,0,0,0};

#ifdef DYNAMIC_LIBRARY
#ifdef __APPLE__
#define EXPORT __attribute__((visibility("default")))
#elif __linux__
#define EXPORT __attribute__((visibility("default")))
#elif _WIN32
#define EXPORT __declspec(dllexport)
#endif
#include <stdlib.h> /* needed for malloc */
/* Auxiliary values */
#ifdef __APPLE__
/* Initializer */
__attribute__((constructor))
static void initializer(void) {
  printf("%s: loaded dynamic library\n", __FILE__);
}
/* Finalizer */
__attribute__((destructor))
static void finalizer(void) {
  printf("%s: unloading dynamic library\n", __FILE__);
}
#elif __linux__
/* Initializer */
__attribute__((constructor))
static void initializer(void) {
  printf("%s: loaded dynamic library\n", __FILE__);
}
/* Finalizer */
__attribute__((destructor))
static void finalizer(void) {
  printf("%s: freed scrapbook, unloading dynamic library\n", __FILE__);
}
#elif _WIN32
#include <windows.h>
BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved)
{
    if (fdwReason == DLL_PROCESS_ATTACH) {
       printf("%s: loaded dynamic library\n", __FILE__);
       return TRUE; }
    else if (fdwReason == DLL_PROCESS_DETACH) {
       printf("%s: freed scrapbook\n", __FILE__);
       return TRUE; }
}
#endif
#else
#define EXPORT 
#endif

EXPORT int counter;

EXPORT
void plus(
   /* inputs */
   double *X1,
   double *X2,
   /* outputs */
   double *Y,
   /* sizes */
   mwSize m,
   mwSize n)
{
  int i;
  printf("Adding [%lu,%lu] matrices (counter=%d)\n",
	 (long unsigned int)m,(long unsigned int)n,++counter);
  for (i=m*n-1;i>=0;i--) {
    Y[i]=X1[i]+X2[i];
  }
}

EXPORT
void mtimes(
   /* inputs */
   double *X1,
   double *X2,
   /* outputs */
   double *Y,
   /* sizes */
   mwSize m,
   mwSize k,
   mwSize n)
{
  int i,j,l;
  printf("Multiplying [%lu,%lu]x[%lu,%lu] matrices (counter=%d)\n",
	 (long unsigned int)m,(long unsigned int)k,
	 (long unsigned int)k,(long unsigned int)n,++counter);
  for (i=0;i<m;i++) {
    for (j=0;j<n;j++) {
      Y[i+m*j] = 0;
      for (l=0;l<k;l++) {
	Y[i+m*j] += X1[i+m*l]*X2[l+k*j];
      }
    }
  }
}

