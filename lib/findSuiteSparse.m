function out=findSuiteSparse();
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

    out=struct('include_paths',{{}},'library_paths',{{}},'libraries',{{}});
    
    paths=which('umfpack');
    paths='/Users/hespanha/GitHub/tenscalc/TimDavis/SuiteSparse/UMFPACK/MATLAB/umfpack.m';
    if ~isempty(paths)
        [paths,name,ext]=fileparts(paths);
        
        out.include_paths={out.include_paths{:},...
                           fsfullfile(paths,'../../include')};
            out.library_paths={out.library_paths{:},...
                            fsfullfile(paths,'../../lib')};
        out.libraries={out.libraries{:},'umfpack'};        
    end
    
end

