function str=mymat2str(mat)
% str=mymat2str(mat)
%   Converts a matrix to a string. Similar to mat2str, but faster,
%   omits the brackets, and handles N-dimensional arrays
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

    if length(size(mat))<=2
        if isempty(mat)
            str='';
        else
            format=repmat('%.20g,',1,size(mat,2));
            format(end)=';';
            str=sprintf(format,mat');
            str(end)=[];
        end
    else
        str=serialize(mat);
        % remove final ';'
        str(end)=[];
    end
end
