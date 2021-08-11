/*
  This file is part of Tencalc.

  Copyright (C) 2012-21 The Regents of the University of California
  (author: Dr. Joao Hespanha).  All rights reserved.
*/

#define M_ 3
#define N_ 4
#define K_ 2

void plus(
   /* inputs */
   const double *X1,
   const double *X2,
   /* outputs */
   double *Y)
{
  int i;
  mexPrintf("Adding [%lu,%lu] matrices\n",M_,N_);
  for (i=M_*N_-1;i>=0;i--) {
    Y[i]=X1[i]+X2[i];
  }
}

void mtimes(
   /* inputs */
   const double *X1,
   const double *X2,
   /* outputs */
   double *Y)
{
  int i,j,l;
  mexPrintf("Multiplying [%lu,%lu]x[%lu,%lu] matrices\n",M_,K_,K_,N_);
  for (i=0;i<M_;i++) {
    for (j=0;j<N_;j++) {
      Y[i+M_*j] = 0;
      for (l=0;l<K_;l++) {
	Y[i+M_*j] += X1[i+M_*l]*X2[l+K_*j];
      }
    }
  }
}
