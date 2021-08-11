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
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.
    
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
    
end

