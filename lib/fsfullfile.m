function str=fsfullfile(varargin)
% Version of matlab's native fullfile() that always use forward slash
% '/' (event in windows)
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.
    for i=1:nargin
        varargin{i}=regexprep(varargin{i},'\','/'); % replace "quotes for MS windows
    end
    str=varargin{1};
    for i=2:nargin
        str=[str,'/',varargin{i}];
    end
    % empty folder should be current directory
    if isempty(varargin{1})
        str(1)=[];
    end
end