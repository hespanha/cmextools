% Copyright 2012-2017 Joao Hespanha

% This file is part of Tencalc.
%
% TensCalc is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version.
%
% TensCalc is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with TensCalc.  If not, see <http://www.gnu.org/licenses/>.

clear all
delete('tmp*');rc=rmdir('@tmp*','s');

template(1).MEXfunction  = 'tmp_Cplus';
template(1).Cfunction = 'plus';
template(1).Sfunction = '';
template(1).method = 'tmp_Cplus';
template(1).inputs(1).type   = 'double';
template(1).inputs(1).name   = 'X1';
template(1).inputs(1).sizes  = {'m','n'};
template(1).inputs(2).type   = 'double';
template(1).inputs(2).name   = 'X2';
template(1).inputs(2).sizes  = {'m','n'};
template(1).outputs(1).type  = 'double';
template(1).outputs(1).name  = 'Y';
template(1).outputs(1).sizes = {'m','n'};

template(2).MEXfunction  = 'tmp_Ctimes';
template(2).Cfunction = 'mtimes';
template(2).Sfunction = '';
template(2).method = 'tmp_Ctimes';
template(2).inputs(1).type   = 'double';
template(2).inputs(1).name   = 'X1';
template(2).inputs(1).sizes  = {'m','k'};
template(2).inputs(2).type   = 'double';
template(2).inputs(2).name   = 'X2';
template(2).inputs(2).sizes  = {'k','n'};
template(2).outputs(1).type  = 'double';
template(2).outputs(1).name  = 'Y';
template(2).outputs(1).sizes = {'m','n'};

classname='tmp_timesplus';
createGateway('template',template,...
              'callType','dynamicLibrary','dynamicLibrary',classname,...
              'CfunctionsSource','times-plus-dylib.c',...
              'className',classname,...
              'verboseLevel',1);

obj=tmp_timesplus();

A=rand(3,2);
B=rand(2,4);
C=rand(3,4);

D=tmp_Ctimes(obj,A,B);
fprintf('tmp_Ctimes... ');
t0=clock;
D=tmp_Ctimes(obj,A,B);
dt=etime(clock,t0);
fprintf('done (%.0f us)\n',1e6*dt);
D
DD=A*B

E=tmp_Cplus(obj,C,D);
fprintf('tmp_Cplus... ');
t0=clock;
E=tmp_Cplus(obj,C,D);
dt=etime(clock,t0);
fprintf('done (%.0f us)\n',1e6*dt);
E
EE=C+D

clear obj;

disp('Erasing generated files');
delete('tmp*');rc=rmdir('@tmp*','s');

