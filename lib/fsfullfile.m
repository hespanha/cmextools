function str=fsfullfile(varargin)
% Version of matlab's native fullfile() that always use forward slash
% '/' (event in windows)
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
    str=varargin{1};
    for i=2:nargin
        str=[str,'/',varargin{i}];
    end
    % empty folder should be current directory
    if isempty(varargin{1})
        str(1)=[];
    end
end