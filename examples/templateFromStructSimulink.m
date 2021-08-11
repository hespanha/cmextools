% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

clear all
delete('tmp*');rc=rmdir('@tmp*','s');

template(1).MEXfunction  = 'tmp_Cplus';
template(1).Sfunction  = 'tmp_Splus';
template(1).Cfunction = 'plus';
template(1).includes  = 'times-plus-fixed.c';
template(1).inputs(1).type   = 'double';
template(1).inputs(1).name   = 'X1';
template(1).inputs(1).sizes  = {'3','4'};
template(1).inputs(2).type   = 'double';
template(1).inputs(2).name   = 'X2';
template(1).inputs(2).sizes  = {'3','4'};
template(1).outputs(1).type  = 'double';
template(1).outputs(1).name  = 'Y';
template(1).outputs(1).sizes = {'3','4'};

template(2).MEXfunction  = 'tmp_Ctimes';
template(2).Sfunction  = 'tmp_Stimes';
template(2).Cfunction = 'mtimes';
template(2).includes  = 'times-plus-fixed.c';
template(2).inputs(1).type   = 'double';
template(2).inputs(1).name   = 'X1';
template(2).inputs(1).sizes  = {'3','2'};
template(2).inputs(2).type   = 'double';
template(2).inputs(2).name   = 'X2';
template(2).inputs(2).sizes  = {'2','4'};
template(2).outputs(1).type  = 'double';
template(2).outputs(1).name  = 'Y';
template(2).outputs(1).sizes = {'3','4'};

createGateway('template',template,...
              'simulinkLibrary','tmp_library','dummySimulinkIOs',true,...
              'verboseLevel',1,...
              'callType','include',...
              ...%'callType','standalone'...
              'verboseLevel',1);
tmp_library;                  % open library;
templateFromStructSimulinkS;  % open simulink file
              
A=rand(3,2);
B=rand(2,4);
C=rand(3,4);

D=tmp_Ctimes(A,B);
fprintf('tmp_Ctimes... ');
t0=clock;
D=tmp_Ctimes(A,B);
dt=etime(clock,t0);
fprintf('done (%.0f us)\n',1e6*dt);
D,
DD=A*B,

E=tmp_Cplus(C,D);
fprintf('tmp_Cplus... ');
t0=clock;
E=tmp_Cplus(C,D);
dt=etime(clock,t0);
fprintf('done (%.0f us)\n',1e6*dt);
E,
EE=C+D,

% run simulink model
sim('templateFromStructSimulinkS');
fprintf('Simulink outputs');
DDD=DDD(:,:,end),
EEE=EEE(:,:,end),

disp('Erasing generated files');
delete('tmp*');rc=rmdir('@tmp*','s');

