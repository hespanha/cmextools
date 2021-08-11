function template=cmextoolsTemplate()
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

    template=struct('MEXfunction',{},...% string
                    'Sfunction',{},...  % string
                    'Cfunction',{},...  % string
                    'method',{},...     % string
                    'help',{},...       % string
                    'inputs',struct(...
                        'type',{},...   % string
                        'name',{},...   % cell-array of strings (one per dimension)
                        'sizes',{}),... % cell-array of strings (one per dimension)
                    'outputs',struct(...% string
                        'type',{},...   % string
                        'name',{},...   % cell-array of strings (one per dimension)
                        'sizes',{}),... % cell-array of strings (one per dimension)
                    'preprocess',{},... % strings (starting with parameters in parenthesis)
                    'includes',{});     % cell-array of strings (one per file)
end
