function [cmd,script]=standaloneCompile(targetComputer,compilerOptimization,standalone,verboseLevel)
% standaloneCompile(targetComputer,compilerOptimization,standalone,verboseLevel)
%   compiles a standalone C program
%
% or
%
% cmd=standaloneCompile(targetComputer,compilerOptimization,standalone,verboseLevel)
%   returns command to compile a standalone C program (but does not
%   execute the command)
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

    libraries={'stdc++'};

    paths=findSuiteSparse();
    include_paths={include_paths{:},paths.include_paths{:}}';
    library_paths={library_paths{:},paths.library_paths{:}}';
    libraries={libraries{:},paths.libraries{:}};

    library_paths_pcwin64=[library_paths;
                        {fsfullfile(mroot,'bin','win64');...
                        fsfullfile(mroot,'extern/lib/bin/win64/microsoft');};
                   ];

    templates.maci64=['clang',...
                      concat(' -I"%s"',include_paths),...
                      concat(' -L"%s"',library_paths),...
                      ' -Wall -Werror -Wno-unused-variable -Wno-unused-result -std=gnu99 ',...
                      ...% %s will be replaced by the compilerOptimization
                      ' %s "',standalone,'.c"',...
                      concat(' -l"%s"',libraries),...
                      ' -o ',standalone];

    templates.glnxa64=['clang',...
                       concat(' -I"%s"',include_paths),...
                       concat(' -L"%s"',library_paths),...
                       ' -Wall -Werror -Wno-unused-variable -Wno-unused-result -std=gnu99 ',...
                       ...% %s will be replaced by the compilerOptimization
                       ' %s "',standalone,'.c"',...
                      concat(' -l"%s"',libraries),...
                      ' -o ',standalone];

    templates.pcwin64=['cl.exe',...
                       concat(' -I"%s"',include_paths),...
                       concat(' /LIBPATH:"%s"',library_paths_pcwin64),...
                       ' /LINK ',...
                       ...% %s will be replaced by the compilerOptimization
                       ' %s "',standalone,'.c"',...
                       concat(' lib%s.lib',libraries),...
                       ' /OUT:',standalone,'.exe'];


   cmd='';
   script{1}=sprintf('switch lower(computer)');

   cases=fieldnames(templates);
   for i=1:length(cases)
        script{end+1}=sprintf('  case ''%s''',lower(cases{i}));
        %script{end+1}=sprintf('    fprintf(''Compiling dynamic library %s.c (%%s)... '',compilerOptimization);t2=clock;',dynamicLibrary);
        script{end+1}=sprintf('    system(sprintf(''%s'',compilerOptimization));',...
                              getfield(templates,cases{i}));
        script{end+1}=sprintf('    fprintf(''done (%%.2f)\\n'',etime(clock(),t2));');
        if strcmp(lower(computer),lower(cases{i}))
            cmd=sprintf(getfield(templates,cases{i}),compilerOptimization);
        end
    end
    script{end+1}='  otherwise';
    script{end+1}='    error(''unsupported computer "%s"\n'',computer);';
    script{end+1}='end';

    if nargout>0
        return
    end

    if verboseLevel>1
        fprintf('Compiling %s.c...\n',standalone);
        fprintf('  %s\n',cmd);
    end
    t2=clock;
    rc=system(cmd);
    if rc
        error('Compilation error %d for %s.c\n',rc,standalone);
    end
    cfile=dir(sprintf('%s.c',standalone));
    efile=dir(sprintf('%s',standalone));
    fprintf(' optimization = %s %s.c = %.3fkB, %s = %.3fkB  (%.3f sec)\n',...
            compilerOptimization,...
            standalone,cfile.bytes/1024,...
            standalone,efile.bytes/1024,etime(clock,t2));

    if verboseLevel>1
        fprintf('  done compiling %s.c (%.2f sec)\n',standalone,etime(clock,t2));
    end
end

function str=concat(format,cell)

    if isempty(cell)
        str='';
    else
        str=sprintf(format,cell{:});
    end
end
