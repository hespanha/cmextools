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
	
	
