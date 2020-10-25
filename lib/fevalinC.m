function varargout=fevalinC(Cfilename,varargin)
% [y1,y2,...]=fevalinC(Cfilename,x1,x2,...)
%
% Evaluates the first matlab function that appears inside the file
% 'Cfilename' containing C code. The matlab code will be extrated from
% the C source file using the C preprocessor (cpp), which will be
% called with a predefined macro named __MATLAB__
%
% Typically, the C-filename will be of the form
%
% #ifdef __MATLAB__
%
% function [y1,y2,...]=f(x1,x2,...)
%
% {matlab code}
%
% end
%
% #else
%
% {C code goes here}
%
% #endif
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

[status,result] = system(sprintf('cpp -P -D__MATLAB__ %s tmp_fevalinC_toremove.m',Cfilename));

if status
    error('Preprocessing error %d, ''%s''\n',status,result);
end

rehash path;

if nargout>0
    varargout=cell(nargout);
    [varargout{:}]=feval('tmp_fevalinC_toremove',varargin{:});
else
    feval('tmp_fevalinC_toremove',varargin{:});
end

!rm -f tmp_fevalinC_toremove.m
