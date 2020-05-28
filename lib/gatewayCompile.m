function [cmd,script]=gatewayCompile(compilerOptimization,mexfolder,mexname,verboseLevel)
% gatewayCompile(compilerOptimization,mexname,verboseLevel)
%   compiles a gateway function,
%
% or
%
% [cmd,script]=gatewayCompile(compilerOptimization,mexname,verboseLevel)
%   returns a command and a computer-independent script to compile
%   the gateway function (but does not compile)
%
% Currently only 'maci64', 'glnxa64', and 'pcwin64' are supported.
%
% Inputs:
%  compilerOptimization - Optimization compiler flags to be used.
%                         Typically '-O0' to '-O4' ot '-Ofast'
%                         depending on the archtecture.
%  mexfolder - Folder where the cmex function will be created
%  mexname   - Input file with the C source code (including
%              full path but NOT the extension). The cmex function
%              will have this same name.
%  verboseLevel - when nonzero, debuging information may be included.
%  
% Outputs:
%  cmd = command to compile the gateway function in the current
%        computer
%  script = cell array with computer-independent script to compile
%           the gateway function. 
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

    mroot=strrep(matlabroot(),'\','/');

    paths=findSuiteSparse();
    include_paths=paths.include_paths;
    library_paths=paths.library_paths;
    libraries=paths.libraries;

    libraries_glnxa64={libraries{:},'dl'};
    
    templates.maci64=['mex -largeArrayDims',...
                      concat(' -I"%s"',include_paths),...
                      concat(' -L"%s"',library_paths),...
                      ' COPTIMFLAGS="%s -DNDEBUG"',...
                      ' CFLAGS="\\$CFLAGS -Wall -Werror -Wno-unused-variable -Wno-unused-result -std=gnu99"',...
                      ' "',mexname,'.c"',...
                      concat(' -l"%s"',libraries),...
                      ' -outdir ',mexfolder];
                      
    templates.glnxa64=['mex -largeArrayDims',...
                      concat(' -I"%s"',include_paths),...
                      concat(' -L"%s"',library_paths),...
                      ' COPTIMFLAGS="%s -DNDEBUG"',...
                      ' CFLAGS="\\$CFLAGS -Wall -Werror -Wno-unused-variable -Wno-unused-result -std=gnu99"',...
                      ' "',mexname,'.c"',...
                      concat(' -l"%s"',libraries_glnxa64),...
                      ' -outdir ',mexfolder];
                     
    templates.pcwin64=templates.maci64;
        
    cmd='';
    script{1}=sprintf('switch lower(computer)');
    
    cases=fieldnames(templates);
    for i=1:length(cases)
        script{end+1}=sprintf('  case ''%s''',lower(cases{i}));
        script{end+1}=sprintf('    eval(sprintf(''%s'',compilerOptimization));',...
                              getfield(templates,cases{i}));
        if strcmp(lower(computer),lower(cases{i}))
            cmd=sprintf(getfield(templates,cases{i}),compilerOptimization);
        end
    end
    script{end+1}='  otherwise';
    script{end+1}='    error(''unsupported computer "%s"\n'',computer);';
    script{end+1}='end';
    
    if isempty(cmd)
        cases
        error('unsupported computer "%s"\n',computer);
    end
                
    if nargout>0
        return
    end
    
    if verboseLevel>1
        fprintf('Compiling %s.c...\n',mexname);
        fprintf('  %s\n',cmd);
        t2=clock;
    end
    eval(cmd);
    if verboseLevel>1
        fprintf('  done compiling %s.c (%.2f sec)\n',mexname,etime(clock,t2));
    end
end

function str=concat(format,cell)
    
    if isempty(cell)
        str='';
    else
        str=sprintf(format,cell{:});
    end
end
