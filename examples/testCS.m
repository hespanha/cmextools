%
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

delete *.mex* @tmpTest/* tmp*
clear;

%% Use csparse to generate C functions that do the actual computations 

Tvariable S 100;
Tvariable X 100;

code=csparse(); 

declareCopy(code,S,full(Tzeros(size(S))),'C_clearS');
declareSet(code,X,'C_setX');
declareCopy(code,S,S+X,'C_addX2S');
declareGet(code,S,'C_getS');

code

mkdir '@tmpTest'

compile2C(code,'C','@tmpTest/tmpTest.c','@tmpTest/tmpTest.h','@tmpTest/tmpTest.log');
% or 
%compile2C(code,'C','tmpTest.c','tmpTest.h','tmpTest.log','@tmpTest');

ls -l @tmpTest

template(1).function='tmpMEX_clearS';
template(1).Cfunction='C_clearS';
template(1).method='clearS';
template(1).inputs=[];
template(1).outputs=[];

template(2).function='tmpMEX_setX';
template(2).Cfunction='C_setX';
template(2).method='setX';
template(2).inputs(1).type='double';
template(2).inputs(1).name='X';
%template(2).inputs(1).sizes={'100'};
template(2).inputs(1).sizes=100;
template(2).outputs=[];

template(3).function='tmpMEX_addX2S';
template(3).Cfunction='C_addX2S';
template(3).method='addX2S';
template(3).inputs=[];
template(3).outputs=[];

template(4).function='tmpMEX_getS';
template(4).Cfunction='C_getS';
template(4).method='getS';
template(4).outputs(1).type='double';
template(4).outputs(1).name='X';
%template(4).outputs(1).sizes={'100'};
template(4).outputs(1).sizes=100;
template(4).inputs=[];

createGateway('template',template,...
              ...%'callType','dynamicLibraryReuse',...
              'callType','standalone',...
              'dynamicLibrary','tmpTest',...
              'compileGateways',true,...
              'compileLibrary',true,...
              'className','tmpTest'...
              );

obj=tmpTest();

clearS(obj);
Scheck=zeros(100,1);
tic
for i=1:1000
    X=rand(100,1);
    setX(obj,X);
    addX2S(obj);
    Scheck=Scheck+X;
end
S=getS(obj);
toc
norm(S-Scheck)
