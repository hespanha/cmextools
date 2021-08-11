% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

clear all
delete('tmp*');rc=rmdir('@tmp*','s');

createGateway('template','times-plus.c');

A=rand(3,2);
B=rand(2,4);
C=rand(3,4);

D=tmp_Ctimes(A,B)
DD=A*B

E=tmp_Cplus(C,D)
EE=C+D

disp('Erasing generated files');
delete('tmp*');rc=rmdir('@tmp*','s');
