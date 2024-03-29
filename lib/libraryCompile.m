function [cmd,script]=libraryCompile(compilerOptimization,...
                                     CfunctionsSource,dynamicLibrary,verboseLevel)
% statistic=libraryCompile(compilerOptimization,...
%                CfunctionsSource,dynamicLibrary,verboseLevel)
%   compiles a dynamic library to be used by matlab
%
% or
%
% [cmd,script]=libraryCompile(compilerOptimization,...
%                    CfunctionsSource,dynamicLibrary,verboseLevel)
%   returns a command and a computer-independent script to compile a
%   dynamic library to be used by matlab (but does not execute the
%   command)
%
% Currently only 'maci64' and 'glnxa64' are supported.
%
% Inputs:
%  compilerOptimization - Optimization compiler flags to be used.
%                         Typically '-O0' to '-O4' ot '-Ofast"
%                         depending on the archtecture.
%  CfunctionsSource - Input file with the C source code (including
%                     full path and extension)
%  dynamicLibrary   - Output file for the dynamic library
%                     (including full path but NOT the extension,
%                     which will be added automatically based on
%                     the computer OS)
%  verboseLevel - when nonzero, debuging information may be included.
%
% Outputs:
%  cmd - command used to compile the library
%  statistics - statistics about the size of the files and compile time
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

    mroot=strrep(matlabroot(),'\','/');

    include_paths={...
        fsfullfile(mroot,'include');
        fsfullfile(mroot,'extern','include') };

    library_paths={...
        fsfullfile(mroot,'bin',lower(computer()))};

    libraries={'mx';'mex';'mat';'stdc++'};
    libraries_pcwin64={'mx';'mex';'mat'};

    if ispc
        % /O2 gives "fatal error C1002: compiler is out of heap space in pass 2"
        compilerOptimization=strrep(compilerOptimization,'-O0','/Od');
        compilerOptimization=strrep(compilerOptimization,'-Ofast','/Ot');
        compilerOptimization=strrep(compilerOptimization,'-O1','/O1');
    end

    paths=findSuiteSparse();
    include_paths={include_paths{:},paths.include_paths{:}};
    library_paths={library_paths{:},paths.library_paths{:}};
    libraries={libraries{:},paths.libraries{:}};
    libraries_pcwin64={libraries_pcwin64{:},paths.libraries{:}};

    library_paths_pcwin64={library_paths{:},...
                        fsfullfile(mroot,'bin','win64'),...
                        fsfullfile(mroot,'extern/lib/win64/microsoft')};

    templates.maci64=['clang',...
                      concat(' -I"%s"',include_paths),...
                      concat(' -L"%s"',library_paths),...
                      ' -Wall -Werror -Wno-unused-variable -Wno-unused-result -std=gnu99 ',...
                      ' -DDYNAMIC_LIBRARY -DNDEBUG',...
                      ' -dynamiclib -fvisibility=hidden -current_version 1.0 -compatibility_version 1.0',...
                      ...% %s will be replaced by the compilerOptimization
                      ' %s "',CfunctionsSource,'"',...
                      concat(' -l"%s"',libraries),...
                      ' -o "',dynamicLibrary,'.dylib"'];

    templates.glnxa64=['clang',...
                       concat(' -I"%s"',include_paths),...
                       concat(' -L"%s"',library_paths),...
                       ' -Wall -Werror -Wno-unused-variable -Wno-unused-result -std=gnu99 ',...
                       ' -DDYNAMIC_LIBRARY -DNDEBUG',...
                       ' -shared -fpic',...
                      ...% %s will be replaced by the compilerOptimization
                       ' %s "',CfunctionsSource,'"',...
                       concat(' -l"%s"',libraries),...
                       ' -o "',dynamicLibrary,'.so"'];

    templates.pcwin64=['cl.exe',...
                       ' /D_USRDLL /D_WINDLL',...
                       concat(' -I"%s"',include_paths),...
                       ' -DDYNAMIC_LIBRARY -DNDEBUG',...
                       ...% %s will be replaced by the compilerOptimization
                       ' %s "',CfunctionsSource,'"',...
                       ' /link /LTCG:OFF'...
                       concat(' /LIBPATH:"%s"',library_paths_pcwin64),...
                       concat(' lib%s.lib',libraries_pcwin64),...
                       ' /DLL /OUT:"',dynamicLibrary,'.dll"'];

   cmd='';
   script{1}=sprintf('switch lower(computer)');

   cases=fieldnames(templates);
   for i=1:length(cases)
        script{end+1}=sprintf('  case ''%s''',lower(cases{i}));
        script{end+1}=sprintf('    fprintf(''Compiling dynamic library %s.c (%%s)... '',compilerOptimization);t2=clock;',dynamicLibrary);
        script{end+1}=sprintf('    system_path(sprintf(''%s'',compilerOptimization));',...
                              getfield(templates,cases{i}));
        script{end+1}=sprintf('    fprintf(''done (%%.2f)\\n'',etime(clock(),t2));');
        if strcmp(lower(computer),lower(cases{i}))
            cmd=sprintf(getfield(templates,cases{i}),compilerOptimization);
        end
    end
    script{end+1}='  otherwise';
    script{end+1}='    error(''unsupported computer "%s"\n'',computer);';
    script{end+1}='end';

    switch lower(computer)
      case 'maci64'
        libraryExtension='dylib';
      case 'glnxa64'
        libraryExtension='so';
        if isempty(findstr('.',getenv('LD_LIBRARY_PATH'))) && isempty(findstr(pwd,getenv('LD_LIBRARY_PATH')))
            fprintf('\nATTENTION: must add ''.'' or ''%s'' to LD_LIBRARY_PATH (LD_LIBRARY_PATH=.;export LD_LIBRARY_PATH)\n',pwd);
        end
      case 'pcwin64'
        libraryExtension='dll';
      otherwise
        error('unsupported computer ''%s''\n',computer);
    end

    if nargout>1
        return
    end

    cfile=dir(sprintf('%s',CfunctionsSource));
    if isempty(cfile)
        error('Cfunctions source file "%s" not found\n',CfunctionsSource)
    end
    statistics.cFileSize=cfile.bytes;

    if verboseLevel>1
        fprintf('  Compiling dynamic library %s.c:\n',dynamicLibrary);
        fprintf('  %s\n',cmd);
    end

    fprintf(' optimization = %s... ',compilerOptimization);
    t2=clock;
    rc=system_path(cmd);
    if rc
        error('Compilation error %d for dynamic library %s.c\n',rc,dynamicLibrary);
    end

    dfile=sprintf('%s.%s',dynamicLibrary,libraryExtension);
    dfile=dir(dfile);
    statistics.dFileSize=dfile.bytes;
    fprintf('%s = %.3fkB, %s.%s = %.3fkB  (%.3f sec)\n',...
            CfunctionsSource,cfile.bytes/1024,...
            dynamicLibrary,libraryExtension,dfile.bytes/1024,etime(clock,t2));

    statistics.dCompileTime=etime(clock,t2);
    cmd=statistics;
    if verboseLevel>1
        fprintf('  done compiling %s.c (%.2f sec)\n',dynamicLibrary,etime(clock,t2));
    end
end

function str=concat(format,cell)

    if isempty(cell)
        str='';
    else
        str=sprintf(format,cell{:});
    end
end
