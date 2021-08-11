/*
  This file is part of Tencalc.

  Copyright (C) 2012-21 The Regents of the University of California
  (author: Dr. Joao Hespanha).  All rights reserved.
*/

#ifdef createGateway

MEXfunction tmp_Cplus

inputs
	double X1 [m,n]
	double X2 [m,n]

outputs
	double Y [m,n]

include   times-plus.c
Cfunction plus

MEXfunction tmp_Ctimes

inputs
	double X1 [m,k]
	double X2 [k,n]

outputs
	double Y [m,n]

include   times-plus.c
Cfunction mtimes

#endif

void plus(
   /* inputs */
   const double *X1,
   const double *X2,
   /* outputs */
   double *Y,
   /* sizes */
   mwSize m,
   mwSize n)
{
  int i;
  mexPrintf("Adding [%lu,%lu] matrices\n",m,n);
  for (i=m*n-1;i>=0;i--) {
    Y[i]=X1[i]+X2[i];
  }
}

void mtimes(
   /* inputs */
   const double *X1,
   const double *X2,
   /* outputs */
   double *Y,
   /* sizes */
   mwSize m,
   mwSize k,
   mwSize n)
{
  int i,j,l;
  mexPrintf("Multiplying [%lu,%lu]x[%lu,%lu] matrices\n",m,k,k,n);
  for (i=0;i<m;i++) {
    for (j=0;j<n;j++) {
      Y[i+m*j] = 0;
      for (l=0;l<k;l++) {
	Y[i+m*j] += X1[i+m*l]*X2[l+k*j];
      }
    }
  }
}
	
	
