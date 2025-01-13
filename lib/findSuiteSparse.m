function out=findSuiteSparse();
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

    out=struct('include_paths',{{}},'library_paths',{{}},'libraries',{{}});

    return % should test if umfpack is working

    paths=which('umfpack');
    %paths='/Users/hespanha/GitHub/tenscalc/TimDavis/SuiteSparse/UMFPACK/MATLAB/umfpack.m';
    if ~isempty(paths)
        [paths,name,ext]=fileparts(paths);

        out.include_paths={out.include_paths{:},...
                           fsfullfile(paths,'../../include')};
            out.library_paths={out.library_paths{:},...
                            fsfullfile(paths,'../../lib')};
        out.libraries={out.libraries{:},'umfpack'};
    end

end
