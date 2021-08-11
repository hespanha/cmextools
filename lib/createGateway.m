function varargout=createGateway(varargin)
% To get help, type createGateway('help')
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

declareParameter(...
    'Help', {
        'Creates a set of gateway cmex functions (which we call *cmex-functions*)'
        'that internally call C functions (which we call the *c-functions*) that'
        'actually perform the necessary computations.';
        ' ';
        'The inputs an outputs to the cmex-functions are specified by a *template*';
        'that specifies the types and sizes of the input-output matlab arrays.';
        'The sizes may be left as variables, which are determined at run-time,';
        'in which case the "unknown" sizes must also be passed as inputs to the'
        'c-functions.'
        ' ';
        'The cmex-functions may (optionally) be encapsulated as a matlab *class*,'
        'which is automatically created. When the c-functions are part of a dynamic library,'
        'this permits the cmex-functions to share variables that are retained across'
        'multiple calls to the cmex-functions.'
        ' ';
        'Several options are possible for how the cmex-functions call the c-function';
        '1) The c-functions may be included directly into the mex-functions code;'
        '   and called directly from the gateway function.';
        '   In this case, source code must be provided for each c-function to be';
        '   included in the gateway function using a #include preprocessor directive.';
        '2) The c-functions are part of a dynamic library that is linked to the'
        '   cmex-functions in run time.';
        '   In this case, source code for the dynamic Library must be provided as a single';
        '   file, which will be compiled as a dynamic library.'
        '3) Each c-function is compiled as a standalone executable, that is executed from';
        '   within the corresponding cmex-function, using the system() command.'
        '   Data is passed between the cmex-function and the c-function by writing to a file.'
        '4) All c-functions are compiled to a standalone executable, which acts a server';
        '   that calls the c-functions at request of the client cmex-functions.';
        '   Data is passed between clients and server through a socket, which permits';
        '   clients and server to run on different computers.';
        ' '
        'Typically, templates are of the form:'
        ' '
        '#ifdef createGateway'
        'MEXfunction MEXmtimes'
        'Sfunction   Smtimes';
        'Cfunction   Cmtimes';
        'method      mtimes';
        'include     Cmtimes.c'
        ' '
        'inputs'
        '	double X1 [m,k]'
        '	uint32 S1 [1]'
        '	double X2 [k,n]'
        '	uint32 S2 [1]'
        ' '
        'outputs'
        '	double Y [m,n]'
        ' '
        'preprocess(V1,V2)'
        ' { ... Matlab code ...}'
        ' '
        'MEXfunction MEXplus'
        'Sfunction   Splus'
        'Cfunction   Cplus'
        'method      plus'
        'include     Cplus.c'
        ' '
        'inputs'
        '	double X1 [m,n]'
        '	uint32 S1 [1]'
        '	double X2 [m,n]'
        '	uint32 S2 [1]'
        ' '
        'outputs'
        '	double Y [m,n]'
        ' '
        'preprocess(V1,V2)'
        ' { ... Matlab code ...}'
        ' '
        '#endif'
        ' '
        'void Cmtimes(double *X1,uint32_t *S1,double *X2,uint32_t *S2,double *Y,'
        '              mwSize m,mwSize k,mwSize n)'
        '{ ... C code ... }'
        ' '
        'void Cplus(double *X1,uint32_t *S1,double *X2,uint32_t *S2,double *Y,'
        '           mwSize mmwSize n)'
        '{ ... C code ... }'
        ' '
        'The ''MEXfunction'' statement defines the name of the cmex-function'
        'to be created. The same template may define several cmex-functions,'
        'each definition starts with a ''MEXfunction'' statement.'
        ' '
        'The ''Sfunction'' statement defines the name of the Simulink S-function'
        'to be created. The same template may define several S-functions,'
        'each definition starts with a ''MEXfunction'' statement.'
        ' '
        'The ''inputs'' section defines inputs to the cmex-function. Pointers to'
        'the storage space of these variables will be available to the c-function.'
        ' '
        'The ''outputs'' section defines the outputs of the cmex-function,'
        'these variable will be created and pointers to the storage space of'
        'these variables will be available to the c-function.'
        '  '
        'Each entry of the ''inputs'' and ''outputs'' section is of the form'
        '   {matlab type} {variable name} [ {array size} ]'
        ' '
        'The {array size} may contain specific numerical values, or'
        'size-variable names. When the same size-variable appears multiple'
        'times, the C gateway function will check for consistency.'
        'The size-variable will be available with the C gateway with type ''mwSize''.'
        'In the ''inputs'' section, the {array size} may contain the symbol ''~'''
        'for some of the dimensions, which means that the dimension will not be'
        'checked by the gateway function.'
        'In the ''outputs'' section, the {array size} may contain valid C'
        'expressions involving size-variables.'
        'If the {array size} of the outputs section is equal to ''~'','
        'then the C gateway function will not allocate storage space,'
        'which will have to be done by the C function.'
        ' '
        'The (optional) ''preprocess'' section defines matlab code that'
        'will be executed after the cmex function is created, but before'
        'the gateway function is written to the file. The code will be evaluated'
        'as a function with the given arguments as input parameters.'
        'This matlab code may be used to generate C code. When this code'
        'is appended to the file ''cmexfunction'', it will appear after'
        'the ''defines'', but before the gateway function.'
        ' '
        'The (optional) ''include'' section defines functions that'
        'should be included (via ''#include'' directives) just before the gateway function.';
        'More than one ''include'' section is possible, resulting in multiple';
        'includes.'
        ' '
        'The ''Cfunction'' statement defines the name of the'
        'C function that carries out the computations. This function will'
        'be called from inside the gateway function with arguments determined'
        'from the ''inputs'' section, including:'
        '  1) pointers to the input variables (data portion)'
        '  2) pointers to the output variables (data portion)'
        '     (automatically allocated)'
        '  3) variables with array sizes'
        ' ';
        'The (optional) method statement defines the name of the method';
        'that calls the cmex function, when the parameter ''className'' is non-empty,';
        'in which case a matlab class is created to call all the cmex-functions.'
        ' ';
        'The initial ''#ifdef'' and the final ''#endif'' are optional. When present,'
        'only the portion of the file between these commands is processed,'
        'otherwise the whole file is processed. '
            });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','template',...
    'Description', {
        'Filename with the template function.'
        ' '
        'Alternatively, templates can be given as a structure array of the form:'
        ' template=struct(...'
        '            ''MEXfunction'',{},... % string = name of the cmex function to be created'
        '            ''Sfunction'',{},...   % string = name of the Simulink S-function to be created'
        '                                   % (empty to prevent creation of the Sfunction)'
        '            ''Cfunction'',{},...   % string = name of the C function that carries out the computation'
        '            ''method'',{},...      % string = name of the matlab method that call the cmex function'
        '                                   %          only used when ''className'' is non-empty'
        '            ''inputs'',struct(...   '
        '                ''type'',{},...    % string'
        '                ''name'',{},...    % cell-array of strings (one per dimension)'
        '                ''sizes'',{}),...  % cell-array of strings/or numeric array (one per dimension) with original sizes'
        '                ''msizes'',{}),... % cell-array of strings/or numeric array (one per dimension) with matlab-compatible sizes'
        '                ''default'',{}),...% default value for the input parameter, only used for matlab class'
        '            ''outputs'',struct(...  % string'
        '                ''type'',{},...    % string'
        '                ''name'',{},...    % cell-array of strings (one per dimension)'
        '                ''sizes'',{}),...  % cell-array of strings/or numeric array (one per dimension) with original sizes'
        '                ''msizes'',{}),... % cell-array of strings/or numeric array (one per dimension) with matlab-compatible sizes'
        '            ''preprocess'',{}..    % strings (starting with parameters in parenthesis)'
        '            ''includes'',{}..      % cell-array of strings (one per file)'
        '            );'
        'in which the different fields of the structure map directly'
        'to the corresponding sections of the template file.'
                   });

declareParameter(...
    'VariableName','simulinkLibrary',...
    'DefaultValue','',...
    'Description', {
        'Name of a simulink library to be created with Simulink blocks that can be used'
        'to call the different functions.'
        'The blocks are created with direct feedthrough.'
        'No library is created if |simulinkLibrary| is an empty string.'
                   });

declareParameter(...
    'VariableName','dummySimulinkIOs',...
    'DefaultValue',false,...
    'AdmissibleValues',{true,false},...
    'Description', {
        'Add one dummy input and one dummy output to the simulink S-functions to enforce'
        'an appropriate order of computation.'
                   });


declareParameter(...
    'VariableName','preprocessParameters',...
    'DefaultValue',{},...
    'Description', {
        'Cell array containing the input parameters to the function(s) defined'
        'in the ''preprocess'' section(s).'
                   });

declareParameter(...
    'VariableName','defines',...
    'DefaultValue',{},...
    'Description', {
        'Matlab structure that specifies a set of #define';
        'preprocessor directives that will be included before the';
        'the #include directive and also before the gateway function'
        'These directives can be used to pass (hardcoded) parameters.';
        'Should be of the form:'
        '      defines.name1 = {string or scalar}';
        '      defines.name2 = {string or scalar}';
        '     .... '
                   });

declareParameter(...
    'VariableName','callType',...
    'DefaultValue','include',...
    'AdmissibleValues',{'include','dynamicLibrary',...
                    'standalone','client-server'},...
    'Description', {
        'Determines how the gateway function should call the C function that'
        'actually performs the computations. It can take the following values'
        '''include'' - The gateway function should call ''Cfunction'','
        '              which must have been defined in the ''includes'''
        '              that precede the declaration of the gateway function.'
        '              The C function will thus be statically linked to the'
        '              gateway function.'
        '''dynamicLibrary'' - Each time the gateway function is called, it:'
        '              (1) The first time a gateway function is called it'
        '                  loads the dynamic library defined by ''dynamicLibrary''';
        '                  (this step is not needed in subsequent calls).'
        '              (2) calls ''Cfunction'' that must exist within the library.'
        '              (3) does NOT unload the dynamic library'
        '              A mexFunction'
        '                 function rc=dynamicLibrary_load(boolean)'
        '              is automatically created to load or unload the library'
        '              It should be called (with boolean=false)'
        '              when the gateways are no longer needed.'
        '              When the cmex functions are incorporated into a matlab class';
        '              (see ''className'' parameters), the creating of the matlab';
        '              object automatically calls dynamicLibrary_load(true);';
        '              BUT the destruction of the object does not call'
        '              dynamicLibrary_load(false), which should be done manually.;';
        '              ATTENTION: the gateway will CRASH matlab if called after'
        '              the library is unloaded.'
        '''standalone'' - The gateway function performs the following tasks:'
        '              (1) writes all input variables to a file,'
        '              (2) calls a standalone executable that reads the inputs'
        '                  and writes the outputs to a file'
        '              (3) reads the outputs from the file created by the'
        '                  standalone executable and returns them'
        '              The standalone executable is automatically created'
        '              and calls the ''Cfunction,'' which are expected to be defined'
        '              in the ''includes''.'
        '              The file IO introduces large overhead, but it is useful for'
	'              debugging and code profiling.'
        '''client-server'' - The gateway function performs the following tasks:'
        '              (1) opens an I/O pipe to communicate with a server that'
        '                  performs the computations'
        '              (2) writes all input variables to the pipe,'
        '              (3) reads the outputs from the pipe and returns them'
        '              The server executable is automatically created'
        '              based on ''CfunctionsSource,'' which is expected to be defined'
        '              When ''className'' is defined, a method ''upload'' is';
        '              automatically created to upload/compile/execute the server';
        '              in ''serverAddress'' using ssh.'
        '              ATTENTION: Currently the serverIP and port are hardcoded'
        '                         in the mex files.';
	'ATTENTION: for both dynamicLibrary types, the types for the parameters'
	'           of ''Cfunction'' are not checked by the compiler.'
        });

declareParameter(...
    'VariableName','CfunctionsSource',...
    'DefaultValue','',...
    'Description', {
        'Name of a .c source file that contains the code for all the c-functions.';
        'This parameter is used only when ''callType'' has one of the values:';
        '''dynamicLibrary''      - source code for the dynamic library';
        '''client-server''       - source code that will be included in the '
        '                          server executable.'
                   });

declareParameter(...
    'VariableName','folder',...
    'DefaultValue','.',...
    'Description', {
        'Path to the folder where the files will be created.';
        'Needs to be in the Matlab path.'
        });

declareParameter(...
    'VariableName','dynamicLibrary',...
    'DefaultValue','',...
    'Description', {
        'Name of the dynamic library (without extension) to be created.'
        'This parameter is used only when ''callType''=''dynamicLibrary''.'
        });

declareParameter(...
    'VariableName','absolutePath',...
    'DefaultValue',true,...
    'AdmissibleValues',{true,false},...
    'Description', {
        'When ''true'' the the cmex functions use an absolute path to open';
        'the dynamic library, which means that the dynamic library cannot';
        'be moved away from the folder where it was created.';
        ' '
        'When ''false'' no path information about the dynamic library is'
        'included in the cmex function, which must then rely on the OS-specific';
        'method used to find dynamic libraries. See documentation of ''dlopen'''
        'for linux and OSX or ''LoadLibrary'' for Microsoft Windows.'
        ' '
        'This parameter is used only when ''callType''=''dynamicLibrary''.'
        });

declareParameter(...
    'VariableName','serverProgramName',...
    'DefaultValue','',...
    'Description', {
        'Name of the executable file for the server executable.'
        'This parameter is used only when ''callType''=''client-server''.'
        });

declareParameter(...
    'VariableName','serverAddress',...
    'DefaultValue','localhost',...
    'Description', {
        'IP address (or name) of the server.'
        'This parameter is used only when ''callType''=''client-server''.'
        });

declareParameter(...
    'VariableName','port',...
    'DefaultValue',1968,...
    'Description', {
        'Port number for the socket that connects client and server.'
        'This parameter is used only when ''callType''=''client-server''.'
        });

declareParameter(...
    'VariableName','compileGateways',...
    'DefaultValue',true,...
    'AdmissibleValues',{true,false},...
    'Description', {
        'When ''true'' the gateway functions are compiled using ''cmex''.'
        });

declareParameter(...
    'VariableName','compileLibrary',...
    'DefaultValue',true,...
    'AdmissibleValues',{true,false},...
    'Description', {
        'When ''true'' the dynamicLibrary is compiled, rather than simply'
        'generating the source code.'
        'This parameter is used only when ''callType''=''dynamicLibrary''.'
       });

declareParameter(...
    'VariableName','compileStandalones',...
    'DefaultValue',true,...
    'AdmissibleValues',{true,false},...
    'Description', {
        'When ''true'' the standalone/server executable is compiled, rather than'
        'simply generating the source code.'
        'This parameter is used only when ''callType'' has one of the values:';
        '   ''standalone'' or ''client-server'''
       });

declareParameter(...
    'VariableName','compilerOptimization',...
    'DefaultValue','-Ofast',...
    'AdmissibleValues',{'-O0','-O1','-O2','-O3','-Os','-Ofast'},...
    'Description', {
        'Optimization flag used for compilation.'
        'Only used when compileGateways, compileLibrary, or compileStandalones'
        });

declareParameter(...
    'VariableName','targetComputer',...
    'DefaultValue',lower(computer),...
    'AdmissibleValues',{'maci64','glnxa64','pcwin64'},...
    'Description', {
        'OS where the mex files will be compiled.'
                   });

declareParameter(...
    'VariableName','serverComputer',...
    'DefaultValue',lower(computer),...
    'AdmissibleValues',{'maci64','glnxa64','pcwin64'},...
    'Description', {
        'OS where the server will be compiled.'
        'This parameter is used only when ''callType''=''client-server''.'
                   });

declareParameter(...
    'VariableName','className',...
    'DefaultValue','',...
    'Description', {
        'When non empty, a class is created that encapsulates all the'
        'gateway functions as methods.'
        'When a dynamicLibrary is used, the class creation loads the library';
        'and the class delete unloads the library.';
        ' ';
        'When a dynamic library is used, the class methods will the library'
        'directly using ''calllib''.'
                   });

declareParameter(...
    'VariableName','classHelp',...
    'DefaultValue','',...
    'Description', {
        'When ''className'' is non empty, this string or string array are';
        'included in the classdef file to provide an help message.'
                   });

declareOutput(...
    'VariableName','statistics',...
    'Description', {
        'Structure with various statistics, including the file sizes and compilations times'
        });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Retrieve parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[stopNow,parameters]=setParameters(nargout,varargin);
if stopNow
    return
end

callLibrary=ismember(callType,{'dynamicLibrary'});

%verboseLevel=4;

if ismember(callType,{'dynamicLibrary'}) && isempty(dynamicLibrary)
    error('createGateway: ''dynamicLibrary'' cannot be empty for callType=''%s''\n',...
          callType);
end

MAGIC=floor(32767*rand(1));

if ismember(callType,{'client-server'}) && isempty(serverProgramName)
    error('createGateway: ''serverProgramName'' cannot be empty for callType=''%s''\n',...
          callType);
end

if ismember(callType,{'dynamicLibrary','client-server'}) && isempty(CfunctionsSource)
    error('createGateway: ''CfunctionsSource''  cannot be empty for callType=''%s''\n',...
          callType);
end

%% Compute class folder & CMEX folder
if isempty(className)
    classFolder='';
    cmexFolder=folder;
else
    if ~isempty(fileparts(className))
        error('className "%s" should not include a path. Use ''folder'' instead.\n',className);
    end
    clear(className); % make sure any previous version of the class
                      % is cleared before overwriting it
    classFolder=fsfullfile(folder,sprintf('@%s',className));
    if ~exist(classFolder,'dir')
        mkdir(classFolder);
        fprintf('createGateway: class folder ''%s'' does not exist, creating it\n',classFolder);
    end
    cmexFolder=fsfullfile(classFolder,'private');
    if ~exist(cmexFolder,'dir')
        mkdir(cmexFolder);
        fprintf('createGateway: private class folder ''%s'' does not exist, creating it\n',cmexFolder);
    end
end

%% Compute path for dynamic library
if ismember(callType,{'dynamicLibrary'})
    if ~isempty(fileparts(dynamicLibrary))
        error('dynamicLibrary (''%s'') should not include a path. Use ''folder'' instead.\n',dynamicLibrary);
    end
    % Retrieve dynamic library's absolute path
    try
        old=cd(cmexFolder);
    catch me
        error('folder ''%s'' to save dynamicLibrary does not exist\n',cmexFolder);
    end
    dynamicLibraryWithPath=fsfullfile(pwd,dynamicLibrary);
    cd(old);
    % Select file name used for dlopen/LoadLibrary
    if absolutePath
        dynamicLibrary_dlopen=dynamicLibraryWithPath;
    else
        dynamicLibrary_dlopen=dynamicLibrary;
        fprintf('No path included for the library, relying on the OS-specific method used to find ''%s''.',dynamicLibrary);
    end
else
    dynamicLibraryWithPath='';
    dynamicLibrary_dlopen='';
end

switch lower(computer)
  case 'maci64'
    compilerOptimization=[compilerOptimization,' -msse -msse2 -msse3 -msse4 -msse4.1'];
  case 'glnxa64'
    compilerOptimization=[compilerOptimization,' -msse -msse2 -msse3 -msse4 -msse4.1'];
  case 'pcwin64'
    compilerOptimization=[compilerOptimization,' /arch:AVX2'];
  otherwise
    error('unsupported computer ''%s''\n',computer);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Read template
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Read template from file, if needed

if ischar(template)
    template=readTemplate(template,verboseLevel);
end

%% Complete missing template fields
for t=1:length(template)
    if ~isfield(template(t),'Sfunction')
        template(t).Sfunction='';
    end
    if ~isfield(template(t),'inputs') || isempty(template(t).inputs)
        template(t).inputs=struct('name',{});
    end
    for i=1:length(template(t).inputs)
        if isnumeric(template(t).inputs(i).sizes)
            template(t).inputs(i).sizes=...
                arrayfun(@(x)sprintf('%g',x),template(t).inputs(i).sizes,'uniform',false);
        end
        le='';
        for j=1:length(template(t).inputs(i).sizes)
            le=[le,template(t).inputs(i).sizes{j},'*'];
        end
        if isempty(le)
            template(t).inputs(i).length=sprintf('sizeof(%s)',...
                                                 matlab2Ctype(template(t).inputs(i).type));
        else
            template(t).inputs(i).length=sprintf('sizeof(%s)*(%s)',...
                                                 matlab2Ctype(template(t).inputs(i).type),...
                                                 le(1:end-1));
        end
        % compute corresponding matlab-compatible sizes
        template(t).inputs(i).msizes=template(t).inputs(i).sizes;
        % pad with 1's till 2 dimensions
        while length(template(t).inputs(i).msizes)<2
            template(t).inputs(i).msizes{end+1}='1';
        end
        % squeeze out trailing singleton dimensions

        while length(template(t).inputs(i).msizes)>2 && isequal(template(t).inputs(i).msizes{end},'1')
            template(t).inputs(i).msizes(end)=[];
        end
    end
    if ~isfield(template(t),'outputs') || isempty(template(t).outputs)
        template(t).outputs=struct('name',{});
    end
    for i=1:length(template(t).outputs)
        if isnumeric(template(t).outputs(i).sizes)
            template(t).outputs(i).sizes=...
                arrayfun(@(x)sprintf('%g',x),template(t).outputs(i).sizes,'uniform',false);
        end
        le='';
        for j=1:length(template(t).outputs(i).sizes)
            le=[le,template(t).outputs(i).sizes{j},'*'];
        end
        if isempty(le)
            template(t).outputs(i).length=sprintf('sizeof(%s)',...
                                                 matlab2Ctype(template(t).outputs(i).type));
        else
            template(t).outputs(i).length=sprintf('sizeof(%s)*(%s)',...
                                                  matlab2Ctype(template(t).outputs(i).type),...
                                                  le(1:end-1));
        end
        % compute corresponding matlab-compatible sizes
        template(t).outputs(i).msizes=template(t).outputs(i).sizes;
        % pad with 1's till 2 dimensions
        while length(template(t).outputs(i).msizes)<2
            template(t).outputs(i).msizes{end+1}='1';
        end
        % squeeze out trailing singleton dimensions
        while length(template(t).outputs(i).msizes)>2 && isequal(template(t).outputs(i).msizes{end},'1' )
            template(t).outputs(i).msizes(end)=[];
        end
    end
    if ~isfield(template(t),'method') || isempty(template(t).method)
        template(t).method=template(t).MEXfunction;
    end
    if ~isfield(template(t),'preprocess')
        template(t).preprocess='';
    else
        if ~isempty(template(t).preprocess)
            template(t).preprocess=['function tmp_toremove',template.preprocess];
        end
    end
    if ~isfield(template(t),'includes')
        template(t).includes={};
    else
        if ischar(template(t).includes)
            template(t).includes={template(t).includes};
        end
    end
    if ~isfield(template(t),'code')
        template(t).code='';
    end
    if ~isfield(template(t),'help')
        template(t).help='';
    end

    % determine "sizes" variables
    template(t).sizes={};
    for i=1:length(template(t).inputs)
        for j=1:length(template(t).inputs(i).sizes)
            if ~isempty(regexp(template(t).inputs(i).sizes{j},'^[a-z_A-Z]\w*$','start'))
                if ~any(strcmp(template(t).inputs(i).sizes{j},template(t).sizes))
                    template(t).sizes{end+1}=template(t).inputs(i).sizes{j};
                end
            end
        end
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create class header
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Create class definition header
if isempty(className)
    fic=[];
else
    name=fsfullfile(classFolder,sprintf('%s.m',className));
    fic=fopen(name,'w');
    if fic<=0
        error('unable to create file ''%s''\n',name);
    end
    fprintf(fic,'classdef %s < handle\n',className);

    if isempty(classHelp)
        classHelp=helpFromTemplate(className,template);
    end
    if ischar(classHelp)
        classHelp{1}=classHelp;
    end
    for i=1:length(classHelp)
        fprintf(fic,'%% %s\n',classHelp{i});
    end
    includeFile(fic,'COPYRIGHT.m','');
    if ismember(callType,{'dynamicLibrary'})
        fprintf(fic,'%% %% Unload dynamic library\n%% load(obj,0)\n');
        fprintf(fic,'%% %% Load dynamic library\n%% load(obj,1)\n');
    end
    fprintf(fic,'   methods\n');
    %% create class creation method
    fprintf(fic,'     function obj=%s()\n',className);
    if ismember(callType,{'dynamicLibrary'})
        if callLibrary
            fprintf(fic,'            [notfound,warnings]=loadlibrary(''%s'',''%s.h'');\n',dynamicLibrary_dlopen,dynamicLibrary_dlopen);
        else
            fprintf(fic,'       load(obj,1);\n',dynamicLibrary);
            %fprintf(fic,'       %s_load(1);\n',dynamicLibrary);
        end
    end
    fprintf(fic,'     end %% %s()\n',className);
    %% create class delete method
    if ismember(callType,{'dynamicLibrary'})
        fprintf(fic,'     function delete(obj)\n');
        if 1
            fprintf(fic,'         fprintf(''deleting object, clear mex, unloading library %s;\\n'');\n',dynamicLibrary);
            if callLibrary
                fprintf(fic,'         unloadlibrary(''%s'');\n',dynamicLibrary);
            else
                %fprintf(fic,'       clear mex;%s_load(0);\n',dynamicLibrary);
                fprintf(fic,'         clear mex;load(obj,0);\n',dynamicLibrary);
            end

        else
            fprintf(fic,'         fprintf(''deleting object, but not unloading library\\n'');\n');
        end
        fprintf(fic,'     end %% delete()\n');
    end
    if strcmp(callType,'client-server')
        %% create upload and compile method for client-server
        fprintf(fic,'     function upload(obj)\n');
        % kill any server running on remote host
        fprintf(fic,'       system(''ssh %s killall %s && echo waiting for remote server to die && sleep 5 '');\n',serverAddress,serverProgramName);
        % copy to remote server
        fprintf(fic,'       system(''scp %s/extern/include/matrix.h %s/extern/include/tmwtypes.h %s:.;ssh %s chmod u+rw matrix.h tmwtypes.h'');\n',...
                matlabroot, matlabroot,serverAddress,serverAddress);
        fprintf(fic,'       system(''scp %s.c %s:.'');\n',...
                serverProgramName,serverAddress);
        % compile in remote server
        cmd=standaloneCompile(serverComputer,compilerOptimization,...
                              fsfullfile(cmexFolder,serverProgramName),verboseLevel);
        fprintf(fic,'       system(''ssh %s %s'');\n',serverAddress,cmd);
        % start remote server
        fprintf(fic,'       system(''ssh %s %s & && echo waiting for remote server to start && sleep 5'');\n',serverAddress,serverProgramName);
        fprintf(fic,'     end %% upload()\n');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create cmex gateway functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Add code to be executed to template structure
template=computeCode(template,callType,callLibrary,dynamicLibrary,dynamicLibrary_dlopen,cmexFolder,...
                     CfunctionsSource,targetComputer,compilerOptimization,...
                     serverComputer,serverProgramName,serverAddress,port,MAGIC,...
                     verboseLevel);

%% Write gateway functions
if verboseLevel>0
    fprintf('writeGateway... ');
    t1=clock;
end

for i=1:length(template)
    writeGateway(template(i).MEXfunction,template(i).Sfunction,template(i).Cfunction,...
                 template(i).inputs,template(i).outputs,template(i).sizes,...
                 defines,template(i).includes,template(i).code,...
                 template(i).preprocess,preprocessParameters,...
                 template(i).callCfunction,template(i).method,...
                 cmexFolder,fic,callType,callLibrary,compilerOptimization,...
                 dynamicLibrary,template(end),...
                 dummySimulinkIOs,...
                 verboseLevel);
end
if verboseLevel>0
    fprintf('done writeGateway (%.2f sec) ',etime(clock,t1));
end

%% Compile gateways
if compileGateways
    fprintf('  Compiling %d MEX gateways... ',length(template));
    t1=clock;
    for i=1:length(template)
        gatewayCompile(compilerOptimization,cmexFolder,...
                       fsfullfile(cmexFolder,template(i).MEXfunction),verboseLevel);
    end
    fprintf('done compiling %d MEX gateways (%.2f sec)\n',length(template),etime(clock,t1));

    % Simulink
    fprintf('  Compiling %d S-function gateways... ',length(template));
    t1=clock;
    for i=1:length(template)
        if ~isempty(template(i).Sfunction)
            gatewayCompile(compilerOptimization,cmexFolder,...
                           fsfullfile(cmexFolder,template(i).Sfunction),verboseLevel);
        end
    end
    fprintf('done compiling %d S-function gateways (%.2f sec)\n',length(template),etime(clock,t1));
end


%% Compile standalones/server
if compileStandalones
    if strcmp(callType,'standalone')
        fprintf('  Compiling %d standalones... ',length(template));
        t1=clock;
        for i=1:length(template)
            standaloneCompile(targetComputer,compilerOptimization,...
                              sprintf('%s_salone',...
                                      fsfullfile(cmexFolder,template(i).MEXfunction)),...
                              verboseLevel);
        end
        fprintf('done compiling %d standalones (%.2f sec)\n',...
                length(template),etime(clock,t1));
    elseif strcmp(callType,'client-server')
        standaloneCompile(serverComputer,compilerOptimization,...
                          fsfullfile(cmexFolder,serverProgramName),verboseLevel);
    end
end

statistics=struct();
%% Create dynamic library
if ismember(callType,{'dynamicLibrary'}) && compileLibrary
    %% Create header for eventually loadlib
    hfilename=sprintf('%s.h',dynamicLibraryWithPath);
    fih=fopen(hfilename,'w');
    if fih<0
        error('createGateway: Unable to create header file ''%s''\n',hfilename);
    end
    fprintf(fih,'/* Created by script createGateway.m on %s */\n\n',datestr(now));
    includeFile(fih,'COPYRIGHT.c');
    [cmd,script]=libraryCompile(compilerOptimization,...
                                CfunctionsSource,dynamicLibraryWithPath,verboseLevel);
    fprintf(fih,'/* %s */\n\n',cmd);
    fprintf(fih,'#include <mex.h>\n');
    fprintf(fih,'#include <stdint.h>\n');

    fprintf(fih,'#ifdef DYNAMIC_LIBRARY\n');
    fprintf(fih,'#ifdef __APPLE__\n');
    fprintf(fih,'#define EXPORT __attribute__((visibility("default")))\n');
    fprintf(fih,'#elif __linux__\n');
    fprintf(fih,'#define EXPORT __attribute__((visibility("default")))\n');
    fprintf(fih,'#elif _WIN32\n');
    fprintf(fih,'#define EXPORT __declspec(dllexport)\n');
    fprintf(fih,'#endif\n');
    fprintf(fih,'#else\n');
    fprintf(fih,'#define EXPORT \n');
    fprintf(fih,'#endif\n');

    for i=1:length(template)
        if ~isempty(template(i).Cfunction)
            fprintf(fih,'EXPORT void %s(%s);\n',template(i).Cfunction,...
                    declareArguments4Cfunction(template(i).inputs,...
                                               template(i).outputs,template(i).sizes));
        end
    end
    fclose(fih);
    %% Compile
    statistics=libraryCompile(compilerOptimization,...
                              CfunctionsSource,dynamicLibraryWithPath,verboseLevel);
end

%% Create compile class
if ~isempty(className) && ~strcmp(callType,'client-server')
    %% create compile method
    fprintf(fic,'     function compile(obj,compilerOptimization)\n');
    fprintf(fic,'       if nargin<2,compilerOptimization=''%s'';end\n',compilerOptimization);

    fprintf(fic,'       switch lower(computer)\n');
    fprintf(fic,'         case ''maci64''\n');
    fprintf(fic,'           compilerOptimization=[compilerOptimization,'' -msse -msse2 -msse3 -msse4 -msse4.1''];\n');
    fprintf(fic,'         case ''glnxa64''\n');
    fprintf(fic,'           compilerOptimization=[compilerOptimization,'' -msse -msse2 -msse3 -msse4 -msse4.1''];\n');
    fprintf(fic,'         case ''pcwin64''\n');
    fprintf(fic,'           compilerOptimization=[compilerOptimization,'' /arch:sse2''];\n');
    fprintf(fic,'         otherwise\n');
    fprintf(fic,'           error(''unsupported computer ''''%%s''''\\n'',computer);\n');
    fprintf(fic,'       end\n');

    % library
    [cmd,script]=libraryCompile(compilerOptimization,...
                                CfunctionsSource,dynamicLibraryWithPath,verboseLevel);
    for j=1:length(script)
        fprintf(fic,'       %s\n',script{j});
    end
    % gateways
    for i=1:length(template)
        [cmd,script]=gatewayCompile(compilerOptimization,cmexFolder,...
                                    fsfullfile(cmexFolder,template(i).MEXfunction),verboseLevel);
        for j=1:length(script)
            fprintf(fic,'       %s\n',script{j});
        end
    end
    fprintf(fic,'     end %% compile()\n');

end

if ~isempty(className)
    %% Close class definition
    fprintf(fic,'   end %% methods\n');
    fprintf(fic,'end %% classdef\n');
    fclose(fic);
end

%% Create Simulink library
if ~isempty(simulinkLibrary)
    close_system(simulinkLibrary,0);
    if exist(simulinkLibrary,'file')
        delete(sprintf('%s.slx',simulinkLibrary));
        rehash;
        warning('Simulink model ''%s'' appears to already exist, erasing it\n',simulinkLibrary);
    end
    fprintf('  Creating simulink library... ',length(template));
    t1=clock;
    new_system(simulinkLibrary,'Library','ErrorIfShadowed');

    for t=1:length(template)
        if ~isempty(template(t).Sfunction)
            blockName=sprintf('%s/%s',simulinkLibrary,template(t).Sfunction);
            add_block('built-in/S-function',blockName);
            set_param(blockName,'name',template(t).Sfunction);         % name below block
            set_param(blockName,'FunctionName',template(t).Sfunction); % block name
            set_param(blockName,'Parameters','');
            set_param(blockName,'SFunctionModules','');
            [xx,yy]=ind2sub([1,50],t);
            set_param(blockName,'position',[600*(xx-.9),150*(yy-.75),600*(xx-.25),150*(yy-.25)]);

            blockPorts=get_param(blockName,'PortHandles');

            % connect inputs to constant blocks of appropriate zeros
            for i=1:length(template(t).inputs)
                sz=str2double(template(t).inputs(i).sizes);
                cName=sprintf('%s/c%d%d (%s)',simulinkLibrary,t,i,index2str(sz));
                add_block('built-in/constant',cName);
                set_param(cName,'value',sprintf('rand(%s)',index2str(sz)));  % constant value
                                                                                %set_param(cName,'name',template(t).inputs(i).name);         % name below block
                set_param(cName,'position',[600*(xx-.9)-100,150*(yy+.25*(i-1)-.75),600*(xx-.9)-50,150*(yy+.25*(i-1)-.75)+20]);
                cPorts=get_param(cName,'PortHandles');
                add_line(simulinkLibrary,cPorts.Outport(1),blockPorts.Inport(i));
            end

            if dummySimulinkIOs
                i=length(template(t).inputs)+1;
                cName=sprintf('%s/cdummy%d',simulinkLibrary,t);
                add_block('built-in/constant',cName);
                set_param(cName,'value',sprintf('rand(1)'));  % constant value
%set_param(cName,'name',template(t).inputs(i).name);         % name below block
                set_param(cName,'position',[600*(xx-.9)-100,150*(yy+.25*(i-1)-.75),600*(xx-.9)-50,150*(yy+.25*(i-1)-.75)+20]);
                cPorts=get_param(cName,'PortHandles');
                add_line(simulinkLibrary,cPorts.Outport(1),blockPorts.Inport(i));
            end

            % connect outputs to constant blocks of appropriate zeros
            for i=1:length(template(t).outputs)
                sz=str2double(template(t).outputs(i).sizes);
                cName=sprintf('%s/p%d%d (%s)',simulinkLibrary,t,i,index2str(sz));
                add_block('simulink/Sinks/Out1',cName);
                %set_param(cName,'value',sprintf('rand(%s)',index2str(sz)));  % constant value
                                                                                %set_param(cName,'name',template(t).outputs(i).name);         % name below block
                set_param(cName,'position',[600*(xx-.25)+100,150*(yy+.25*(i-1)-.75),600*(xx-.25)+150,150*(yy+.25*(i-1)-.75)+20]);
                cPorts=get_param(cName,'PortHandles');
                add_line(simulinkLibrary,blockPorts.Outport(i),cPorts.Inport(1));
            end

            if dummySimulinkIOs
                i=length(template(t).outputs)+1;
                cName=sprintf('%s/pdummy%d',simulinkLibrary,t);
                add_block('simulink/Sinks/Out1',cName);
                %set_param(cName,'value',sprintf('rand(1)'));  % constant value
%set_param(cName,'name',template(t).outputs(i).name);         % name below block
                set_param(cName,'position',[600*(xx-.25)+100,150*(yy+.25*(i-1)-.75),600*(xx-.25)+150,150*(yy+.25*(i-1)-.75)+20]);
                cPorts=get_param(cName,'PortHandles');
                add_line(simulinkLibrary,blockPorts.Outport(i),cPorts.Inport(1));
            end

        end
    end

    save_system(simulinkLibrary);
    fprintf('done (%.2f sec)\n',etime(clock,t1));
end

%% load library
if ismember(callType,{'dynamicLibrary'})
    loadname=sprintf('%s_load',dynamicLibrary);
    if exist(loadname,'file')
        % unload any previously loaded library
        feval(loadname,0);
        % load new library
        feval(loadname,1);
    else
        fprintf('createGateway: dynamicLibrady file ''%s'' NOT IN PATH\n',loadname);
    end
end

rehash path;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set outputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

varargout=setOutputs(nargout,template);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Read template from file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function template=readTemplate(template,verboseLevel)

    fcmext=fopen(template);

    template=struct('MEXfunction',{},...   % string
                    'Sfunction',{},...  % string
                    'Cfunction',{},...  % string
                    'method',{},...  % string
                    'inputs',struct(...
                        'type',{},...   % string
                        'name',{},...   % cell-array of strings (one per dimension)
                        'sizes',{}),... % cell-array of strings (one per dimension)
                    'outputs',struct(... % string
                        'type',{},...   % string
                        'name',{},...   % cell-array of strings (one per dimension)
                        'sizes',{}),... % cell-array of strings (one per dimension)
                    'preprocess',{},... % strings (starting with parameters in parenthesis)'
                    'includes',{});     % cell-array of strings (one per file)

    linenum=0;
    [nextline,linenum]=getLine(fcmext,linenum);
    while 1
        if verboseLevel>2
            fprintf('  %d: "%s"\n',linenum,nextline);
        end

        % #endif
        if isempty(nextline) || ~isempty(regexp(nextline,'^#endif$','start'))
            return
        end

        % #ifdef createGateway ?
        if ~isempty(regexp(nextline,'^#ifdef\s+createGateway$','start'))
            [nextline,linenum]=getLine(fcmext,linenum);
            continue;
        end

        % function xxxx
        S=regexp(nextline,'^MEXfunction\s+(\w+)$','tokens');
        if ~isempty(S)
            template(end+1).MEXfunction=S{1}{1};
            template(end).inputs=struct('name',{});
            template(end).outputs=struct('name',{});
            template(end).preprocessParameters='';
            template(end).includes={};
            template(end).Cfunction='';
            template(end).Sfunction='';
            [nextline,linenum]=getLine(fcmext,linenum);
            continue;
        end

        % inputs
        S=regexp(nextline,'^inputs$','tokens');
        if ~isempty(S)
            [template(end).inputs,nextline,linenum]=...
                readVariables(fcmext,linenum,template(end).inputs);
            continue;
        end

        % outputs
        S=regexp(nextline,'^outputs$','tokens');
        if ~isempty(S)
            [template(end).outputs,nextline,linenum]=...
                readVariables(fcmext,linenum,template(end).outputs);
            continue;
        end

        % include xxxx
        S=regexp(nextline,'^include\s+([-//\\\w.]+)$','tokens');
        if ~isempty(S)
            template(end).includes{end+1}=S{1}{1};
            [nextline,linenum]=getLine(fcmext,linenum);
            continue;
        end

        % Cfunction xxxx
        S=regexp(nextline,'^Cfunction\s+(\w+)$','tokens');
        if ~isempty(S)
            if ~isempty(template(end).Cfunction)
                fprintf('%d: "%s"\n',linenum,nextline);
                error('createGateway: 2nd Cfunction found in line %d\n',linenum);
            end
            template(end).Cfunction=S{1}{1};
            [nextline,linenum]=getLine(fcmext,linenum);
            continue;
        end

        % Sfunction xxxx
        S=regexp(nextline,'^SSfunction\s+(\w+)$','tokens');
        if ~isempty(S)
            if ~isempty(template(end).Sfunction)
                fprintf('%d: "%s"\n',linenum,nextline);
                error('createGateway: 2nd Sfunction found in line %d\n',linenum);
            end
            template(end).Sfunction=S{1}{1};
            [nextline,linenum]=getLine(fcmext,linenum);
            continue;
        end

        % method xxxx
        S=regexp(nextline,'^method\s+(\w+)$','tokens');
        if ~isempty(S)
            if ~isempty(template(end).method)
                fprintf('%d: "%s"\n',linenum,nextline);
                error('createGateway: 2nd method found in line %d\n',linenum);
            end
            template(end).method=S{1}{1};
            [nextline,linenum]=getLine(fcmext,linenum);
            continue;
        end

        % preprocess( ... )
        S=regexp(nextline,'^preprocess\(([\w,]+)\)$','tokens');
        if ~isempty(S)
            if ~isempty(template.preprocess)
                fprintf('%d: "%s"\n',linenum,nextline);
                error('createGateway: 2nd preprocess found in line %d\n',linenum);
            end
            [template(end).preprocess,nextline,linenum]=...
                readPreprocess(fcmext,linenum,S{1}{1});
            continue;
        end

        fprintf('%d: "%s"\n',linenum,nextline);
        error('createGateway: unexpected command in line %d\n',linenum);

    end

    fclose(fcmext);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Add code to be executed to the template structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function template=computeCode(template,callType,callLibrary,dynamicLibrary,dynamicLibrary_dlopen,folder,...
                              CfunctionsSource,targetComputer,compilerOptimization,...
                              serverComputer,serverProgramName,serverAddress,port,magic,...
                              verboseLevel)

    if strcmp(callType,'client-server')
        cfilename=sprintf('%s.c',serverProgramName);
        fmid=fopen(cfilename,'w');
        if fmid<0
            error('createGateway: Unable to create C file ''%s''\n',cfilename);
        end
        fprintf(fmid,'/* Created by script createGateway.m on %s */\n\n',datestr(now));
        includeFile(fmid,'COPYRIGHT.c');
        cmd=standaloneCompile(serverComputer,compilerOptimization,...
                              fsfullfile(folder,serverProgramName),verboseLevel);
        fprintf(fmid,'/* %s */\n\n',cmd);
        fprintf(fmid,'#include <fcntl.h>\n');
        fprintf(fmid,'#include <unistd.h>\n');
        fprintf(fmid,'#include <stdio.h>\n');
        fprintf(fmid,'#include <matrix.h>\n');
        fprintf(fmid,'#define mexPrintf(...) fprintf (stderr, __VA_ARGS__)\n\n');
        ph=fileparts(which('createGateway'));
        %fprintf(fmid,'#include "%s"\n',fsfullfile(ph,'server.c'));
        includeFile(fmid,fsfullfile(ph,'server.c'));
        if ~isempty(CfunctionsSource)>0
            %fprintf(fmid,'#include "%s"\n',CfunctionsSource);
            includeFile(fmid,CfunctionsSource);
            fprintf(fmid,'\n');
        end
        fprintf(fmid,'int main() {\n');
        fprintf(fmid,'  int sockfd=initServer(%d);\n',port);
        fprintf(fmid,'      fprintf(stderr,"%s: sockfd=%%d\\n",sockfd);\n',serverProgramName);
        fprintf(fmid,'      while (1) {\n');
        fprintf(fmid,'         int fid=wait4client(sockfd);\n',port);
        fprintf(fmid,'         fprintf(stderr,"%s: fid=%%d\\n",fid);\n',serverProgramName);
        fprintf(fmid,'         int method=-1;\n');
        fprintf(fmid,'         int magic=-1;\n');
        fprintf(fmid,'         read(fid,&magic,sizeof(magic));\n');
        fprintf(fmid,'         fprintf(stderr,"%s: magic=%%d\\n",magic);\n',serverProgramName);
        fprintf(fmid,'         read(fid,&method,sizeof(method));\n');
        fprintf(fmid,'         fprintf(stderr,"%s: method=%%d\\n",method);\n',...
                serverProgramName);
        fprintf(fmid,'         if (magic != %d) exit(1);\n',magic);
        fprintf(fmid,'         switch (method) {\n');
    end

    for t=1:length(template)
        switch callType

          case 'include'
            template(t).callCfunction=sprintf(...
                '   %s(%s);\n',template(t).Cfunction,...
                callArguments4Cfunction(template(t).inputs,...
                                        template(t).outputs,template(t).sizes));

          case 'dynamicLibrary'
            template(t).callCfunction='';
            if verboseLevel>3
                template(t).callCfunction=[template(t).callCfunction,sprintf('   printf("call %s (before):\tP%s=%%lx\\n",P%s);\n',template(t).Cfunction,template(t).Cfunction,template(t).Cfunction)];
                template(t).callCfunction=[template(t).callCfunction,sprintf('   printf("\t\t\tlibHandle=%%lx\\n",libHandle);\n')];
            end
            template(t).callCfunction=[template(t).callCfunction,sprintf('   if (!P%s) {\n',template(t).Cfunction);];
            template(t).callCfunction=[template(t).callCfunction,sprintf('#ifdef __linux__\n')];
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('     libHandle = dlopen("%s.so", RTLD_NOW);\n',...
                                        dynamicLibrary_dlopen)];
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('     if (!libHandle) { printf("[%%s] Unable to open library: %%s\\n",__FILE__, dlerror());return; }\n')];
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('     P%s = dlsym(libHandle, "%s");\n',...
                                        template(t).Cfunction,template(t).Cfunction)];
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('     if (!P%s) { printf("[%%s] Unable to get symbol: %%s\\n",__FILE__, dlerror());return; }// else { printf("[%%s] Got symbol: %s = 0x%%" PRIXPTR"\\n",__FILE__, P%s);}\n',...
                                        template(t).Cfunction,template(t).Cfunction,template(t).Cfunction)];
            template(t).callCfunction=[template(t).callCfunction,sprintf('#elif __APPLE__\n')];
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('     libHandle = dlopen("%s.dylib", RTLD_NOW);\n',...
                                        dynamicLibrary_dlopen)];
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('     if (!libHandle) { printf("[%%s] Unable to open library: %%s\\n",__FILE__, dlerror());return; }\n')];
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('     P%s = dlsym(libHandle, "%s");\n',...
                                        template(t).Cfunction,template(t).Cfunction)];
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('     if (!P%s) { printf("[%%s] Unable to get symbol: %%s\\n",__FILE__, dlerror());return; }// else { printf("[%%s] Got symbol: %s = 0x%%" PRIXPTR"\\n",__FILE__, P%s);}\n',...
                                        template(t).Cfunction,template(t).Cfunction,template(t).Cfunction)];
            template(t).callCfunction=[template(t).callCfunction,sprintf('#elif _WIN32\n')];
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('     libHandle = LoadLibrary("%s.dll");\n',...
                                        dynamicLibrary_dlopen)];
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('     if (!libHandle) { printf("[%%s] Unable to open library\\n",__FILE__);return; }\n')];
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('     P%s = GetProcAddress(libHandle, "%s");\n',...
                                        template(t).Cfunction,template(t).Cfunction)];
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('     if (!P%s) { printf("[%%s] Unable to get symbol\\n",__FILE__);return; }\n',...
                                        template(t).Cfunction)];
            template(t).callCfunction=[template(t).callCfunction,sprintf('#endif // _WIN32\n')];

            template(t).callCfunction=[template(t).callCfunction,sprintf('   }\n')];

            if verboseLevel>3
                template(t).callCfunction=[template(t).callCfunction,sprintf('   printf("call %s (after):\tP%s=%%lx\\n",P%s);\n',template(t).Cfunction,template(t).Cfunction,template(t).Cfunction)];
                template(t).callCfunction=[template(t).callCfunction,sprintf('   printf("\t\t\tlibHandle=%%lx\\n",libHandle);\n')];
            end

            template(t).callCfunction=[template(t).callCfunction,sprintf('   P%s(%s);\n',...
                                                              template(t).Cfunction,...
                                                              callArguments4Cfunction(...
                                                                  template(t).inputs,...
                                                                  template(t).outputs,...
                                                                  template(t).sizes))];

          case 'standalone'
            % save data to file
            template(t).callCfunction=sprintf(' { int fid=open("%s.bin",O_CREAT|O_RDWR|O_TRUNC,S_IRUSR|S_IWUSR);\n',...
                                              template(t).MEXfunction);
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('       if (fid<0) mexErrMsgIdAndTxt("%s:prhs","unable to open \\"%s.bin\\"");\n',...
                                        template(t).MEXfunction,template(t).MEXfunction)];
            if length(template(t).sizes)>0
                template(t).callCfunction=[template(t).callCfunction,...
                                    sprintf('   /* sizes */\n')];
            end
            % write sizes
            for i=1:length(template(t).sizes)
                template(t).callCfunction=[template(t).callCfunction,...
                                    sprintf('      write(fid,&%s,sizeof(%s));\n',...
                                            template(t).sizes{i},template(t).sizes{i})];
            end
            % write inputs
            if length(template(t).inputs)>0
                template(t).callCfunction=[template(t).callCfunction,...
                                    sprintf('   /* inputs */\n')];
            end
            for i=1:length(template(t).inputs)
                template(t).callCfunction=[template(t).callCfunction,...
                                    sprintf('      write(fid,%s,%s);\n',...
                                            template(t).inputs(i).name,...
                                            template(t).inputs(i).length)];
                template(t).callCfunction=[template(t).callCfunction,...
                                    sprintf('      //fprintf(stderr,"%s: wrote %%ld bytes to %s [%%lg...]\\n",%s,(double)%s[0]);\n',...
                                            template(t).MEXfunction,...
                                            template(t).inputs(i).name,...
                                            template(t).inputs(i).length,...
                                            template(t).inputs(i).name)];
            end
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('   /* call standalone program */\n')];
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('      system("%s_salone");\n',template(t).MEXfunction)];

            % read outputs
            if length(template(t).outputs)>0
                template(t).callCfunction=[template(t).callCfunction,...
                                    sprintf('   /* outputs */\n')];
            end
            for i=1:length(template(t).outputs)
                template(t).callCfunction=[template(t).callCfunction,...
                                    sprintf('    /*{ ssize_t nbytes=*/read(fid,%s,%s);\n',...
                                            template(t).outputs(i).name,...
                                            template(t).outputs(i).length)];
                template(t).callCfunction=[template(t).callCfunction,...
                                    sprintf('      /*fprintf(stderr,"%s: read %%ld bytes to %s [%%lg...], %%ld bytes expected\\n",nbytes,(double)%s[0],%s); }*/\n',...
                                            template(t).MEXfunction,...
                                            template(t).outputs(i).name,...
                                            template(t).outputs(i).name,...
                                            template(t).outputs(i).length)];
            end

            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('   close(fid); }\n')];

            %% create standalone main()
            cfilename=sprintf('%s_salone.c',template(t).MEXfunction);
            fmid=fopen(cfilename,'w');
            if fmid<0
                error('createGateway: Unable to create C file ''%s''\n',cfilename);
            end
            fprintf(fmid,'/* Created by script createGateway.m on %s */\n\n',datestr(now));
            includeFile(fmid,'COPYRIGHT.c');
            cmd=standaloneCompile(targetComputer,compilerOptimization,...
                                  sprintf('%s_salone',...
                                          fsfullfile(folder,template(i).MEXfunction)),...
                                  verboseLevel);
            fprintf(fmid,'/* %s */\n\n',cmd);
            %fprintf(fmid,'#include <string.h>\n');
            %fprintf(fmid,'#include <stdint.h>\n');
            %fprintf(fmid,'#include <pthread.h>\n');
            fprintf(fmid,'#include <fcntl.h>\n');
            fprintf(fmid,'#include <unistd.h>\n');
            fprintf(fmid,'#include <stdio.h>\n');
            fprintf(fmid,'#include <matrix.h>\n');
            fprintf(fmid,'#define mexPrintf(...) fprintf (stderr, __VA_ARGS__)\n\n');

            % declare function that does work
            fprintf(fmid,'extern void %s(%s);\n\n',template(t).Cfunction,...
                    declareArguments4Cfunction(template(t).inputs,...
                                               template(t).outputs,template(t).sizes));

            if size(template(t).includes,1)>0
                fprintf(fmid,'#include "%s"\n',template(t).includes{:});
                fprintf(fmid,'\n');
            end

            fprintf(fmid,'int main() { \n');
            % open communication file
            fprintf(fmid,'  int fid=open("%s.bin",O_RDWR,0);\n',template(t).MEXfunction);
            fprintf(fmid,'      fprintf(stderr,"%s_salone: fid=%%d (\\"%s.bin\\")\\n",fid);\n',...
                    template(t).MEXfunction,template(t).MEXfunction);
            fprintf(fmid,'      if (fid<0) exit(1);\n');

            % declare variables
            fprintf(fmid,'%s',declareVariables(template(t).inputs,...
                                               template(t).outputs,template(t).sizes));
            % read sizes
            fprintf(fmid,'\n   /* read sizes */\n');
            for i=1:length(template(t).sizes)
                fprintf(fmid,'   read(fid,&%s,sizeof(%s));\n',...
                        template(t).sizes{i},template(t).sizes{i});
                fprintf(fmid,'   fprintf(stderr,"%s_salone: read %%ld bytes to %s=%%ld\\n",sizeof(%s),%s);\n',...
                        template(t).MEXfunction,template(t).sizes{i},...
                        template(t).sizes{i},template(t).sizes{i});
            end
            % read inputs
            if length(template(t).inputs)>0
                fprintf(fmid,'   /* read inputs */\n');
            end
            for i=1:length(template(t).inputs)
                fprintf(fmid,'   if ((%s=malloc(%s))==NULL) exit(1);\n',...
                        template(t).inputs(i).name,template(t).inputs(i).length);
                fprintf(fmid,' /*{ ssize_t nbytes=*/read(fid,%s,%s);\n',...
                        template(t).inputs(i).name,template(t).inputs(i).length);
                fprintf(fmid,'   /*fprintf(stderr,"%s_salone: read %%lu bytes to %s [%%lg...]\\n",nbytes,%s[0]);}*/\n',...
                        template(t).MEXfunction,template(t).inputs(i).name,...
                        template(t).inputs(i).name);
            end
            if length(template(t).outputs)>0
                fprintf(fmid,'   /* allocate memory for outputs */\n');
            end
            for i=1:length(template(t).outputs)
                fprintf(fmid,'   if ((%s=malloc(%s))==NULL) exit(1);\n',...
                        template(t).outputs(i).name,...
                        template(t).outputs(i).length);
            end
            % call function that does work
            fprintf(fmid,'   /* call function */\n');
            fprintf(fmid,'   %s(%s);\n',template(t).Cfunction,...
                    callArguments4Cfunction(template(t).inputs,...
                                            template(t).outputs,...
                                            template(t).sizes));
            % write outputs
            if length(template(t).outputs)>0
                fprintf(fmid,'   /* write outputs */\n');
            end
            for i=1:length(template(t).outputs)
                fprintf(fmid,'   //fprintf(stderr,"%s_salone: writing %%lu bytes to %s [%%lg...]\\n",%s,(double)%s[0]);\n',...
                        template(t).MEXfunction,template(t).outputs(i).name,...
                        template(t).outputs(i).length,template(t).outputs(i).name);
                fprintf(fmid,'   write(fid,%s,%s);\n',...
                        template(t).outputs(i).name,template(t).outputs(i).length);
            end
            fprintf(fmid,'   close(fid);\n');
            % close main function
            fprintf(fmid,'} // main()\n');
            fclose(fmid);

          case 'client-server'
            % send data through pipe
            template(t).callCfunction=sprintf('   /* Send data through pipe */\n');
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf(' { int method=%d;\n',t)];
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('   int magic=%d;\n',magic)];
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('   int fid=connect2server("%s",%d);\n',...
                                        serverAddress,port)];
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('       if (fid<0) mexErrMsgIdAndTxt("%s:prhs","unable to connect to server");\n',...
                                        template(t).MEXfunction)];
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('       write(fid,&magic,sizeof(magic));\n')];
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('       write(fid,&method,sizeof(method));\n')];
            if length(template(t).sizes)>0
                template(t).callCfunction=[template(t).callCfunction,...
                                    sprintf('   /* sizes */\n')];
            end
            % write sizes
            for i=1:length(template(t).sizes)
                template(t).callCfunction=[template(t).callCfunction,...
                                    sprintf('      uint64_t %s_64=%s;write(fid,&%s_64,sizeof(%s_64));\n',...
                                            template(t).sizes{i},template(t).sizes{i},...
                                            template(t).sizes{i},template(t).sizes{i})];
            end
            % write inputs
            if length(template(t).inputs)>0
                template(t).callCfunction=[template(t).callCfunction,...
                                    sprintf('   /* inputs */\n')];
            end
            for i=1:length(template(t).inputs)
                template(t).callCfunction=[template(t).callCfunction,...
                                    sprintf('      write(fid,%s,%s);\n',...
                                            template(t).inputs(i).name,...
                                            template(t).inputs(i).length)];
                template(t).callCfunction=[template(t).callCfunction,...
                                    sprintf('      //fprintf(stderr,"%s: wrote %%ld bytes to %s [%%lg...]\\n",%s,(double)%s[0]);\n',...
                                            template(t).MEXfunction,...
                                            template(t).inputs(i).name,...
                                            template(t).inputs(i).length,...
                                            template(t).inputs(i).name)];
            end
            % read outputs
            if length(template(t).outputs)>0
                template(t).callCfunction=[template(t).callCfunction,...
                                    sprintf('   /* outputs */\n')];
            end
            for i=1:length(template(t).outputs)
                template(t).callCfunction=[template(t).callCfunction,...
                                    sprintf('    /*{ ssize_t nbytes=*/read(fid,%s,%s);\n',...
                                            template(t).outputs(i).name,...
                                            template(t).outputs(i).length)];
                template(t).callCfunction=[template(t).callCfunction,...
                                    sprintf('      /*fprintf(stderr,"%s: read %%ld bytes to %s [%%lg...], %%ld bytes expected\\n",nbytes,(double)%s[0],%s); }*/\n',...
                                            template(t).MEXfunction,...
                                            template(t).outputs(i).name,...
                                            template(t).outputs(i).name,...
                                            template(t).outputs(i).length)];
            end
            template(t).callCfunction=[template(t).callCfunction,...
                                sprintf('    close(fid);\n  }\n');];

            %% server's code
            fprintf(fmid,'           case %d: {\n',t);
            fprintf(fmid,'%s',...
                    declareVariables(template(t).inputs,...
                                     template(t).outputs,template(t).sizes));
            % read sizes
            fprintf(fmid,'             /* read sizes */\n');
            for i=1:length(template(t).sizes)
                fprintf(fmid,'             uint64_t %s_64;read(fid,&%s_64,sizeof(%s_64));%s=%s_64;\n',...
                        template(t).sizes{i},template(t).sizes{i},template(t).sizes{i},template(t).sizes{i},template(t).sizes{i});
                fprintf(fmid,'             fprintf(stderr,"%s: read %%lu bytes to %s=%%lu\\n",(long unsigned int)sizeof(%s_64),(long unsigned int)%s);\n',...
                        serverProgramName,template(t).sizes{i},...
                        template(t).sizes{i},template(t).sizes{i});
            end
            % read inputs
            if length(template(t).inputs)>0
                fprintf(fmid,'             /* read inputs */\n');
            end
            for i=1:length(template(t).inputs)
                fprintf(fmid,'             if ((%s=malloc(%s))==NULL) exit(1);\n',...
                        template(t).inputs(i).name,template(t).inputs(i).length);
                fprintf(fmid,' /*{ ssize_t nbytes=*/read(fid,%s,%s);\n',...
                        template(t).inputs(i).name,template(t).inputs(i).length);
                fprintf(fmid,'             /*fprintf(stderr,"%s: read %%lu bytes to %s [%%lg...]\\n",nbytes,%s[0]);}*/\n',...
                        serverProgramName,template(t).inputs(i).name,...
                        template(t).inputs(i).name);
            end
            if length(template(t).outputs)>0
                fprintf(fmid,'             /* allocate memory for outputs */\n');
            end
            for i=1:length(template(t).outputs)
                fprintf(fmid,'             if ((%s=malloc(%s))==NULL) exit(1);\n',...
                        template(t).outputs(i).name,...
                        template(t).outputs(i).length);
            end
            % call function that does work
            fprintf(fmid,'             /* call function */\n');
            fprintf(fmid,'             %s(%s);\n',template(t).Cfunction,...
                    callArguments4Cfunction(template(t).inputs,...
                                            template(t).outputs,template(t).sizes));
            % write outputs
            if length(template(t).outputs)>0
                fprintf(fmid,'             /* write outputs */\n');
            end
            for i=1:length(template(t).outputs)
                fprintf(fmid,'             //fprintf(stderr,"%s: writing %%lu bytes to %s [%%lg...]\\n",%s,(double)%s[0]);\n',...
                        serverProgramName,template(t).outputs(i).name,...
                        template(t).outputs(i).length,template(t).outputs(i).name);
                fprintf(fmid,'             write(fid,%s,%s);\n',...
                        template(t).outputs(i).name,template(t).outputs(i).length);
            end
            for i=1:length(template(t).inputs)
                fprintf(fmid,'             free(%s);\n',template(t).inputs(i).name);
            end
            for i=1:length(template(t).outputs)
                fprintf(fmid,'             free(%s);\n',template(t).outputs(i).name);
            end
            fprintf(fmid,'             break;}\n');

          otherwise
            error('createGateway: unknown callType %s\n',callType);
        end
    end

    if strcmp(callType,'client-server')
        % close main function
        fprintf(fmid,'      } // switch ()\n');
        fprintf(fmid,'      close(fid);\n');
        fprintf(fmid,'   } // while ()\n');
        fprintf(fmid,'} // main()\n');
        fclose(fmid);
    end

    if strcmp(callType,'dynamicLibrary') && ~callLibrary
        template(end+1).MEXfunction=sprintf('%s_load',dynamicLibrary);
        template(end).Sfunction='';
        template(end).method='load';
        template(end).inputs(1).name='load';
        template(end).inputs(1).type='double';
        template(end).inputs(1).sizes={'1','1'};
        template(end).inputs(1).msizes={'1','1'};
        template(end).preprocessParameters='';
        template(end).includes={};
        template(end).Cfunction='';
        template(end).callCfunction='';

        if verboseLevel>3
            template(end).callCfunction=[template(end).callCfunction,sprintf('  printf("%s_load (before):\tlibHandle=%%lx, load=%%lf\\n",libHandle,load[0]);\n',dynamicLibrary)];
        end

        template(end).callCfunction=[template(end).callCfunction,sprintf('  if (!libHandle || load[0]) {\n')];

        template(end).callCfunction=[template(end).callCfunction,sprintf('#ifdef __linux__\n')];
        template(end).callCfunction=[template(end).callCfunction,...
                            sprintf('     libHandle = dlopen("%s.so", RTLD_NOW);\n',...
                                    dynamicLibrary_dlopen)];
        template(end).callCfunction=[template(end).callCfunction,...
                            sprintf('     if (!libHandle) { printf("[%%s] Unable to open library: %%s\\n",__FILE__, dlerror());return; }\n')];
        template(end).callCfunction=[template(end).callCfunction,sprintf('#elif __APPLE__\n')];
        template(end).callCfunction=[template(end).callCfunction,...
                            sprintf('     libHandle = dlopen("%s.dylib", RTLD_NOW);\n',...
                                    dynamicLibrary_dlopen)];
        template(end).callCfunction=[template(end).callCfunction,...
                            sprintf('     if (!libHandle) { printf("[%%s] Unable to open library: %%s\\n",__FILE__, dlerror());return; }\n')];
        template(end).callCfunction=[template(end).callCfunction,sprintf('#elif _WIN32\n')];
        template(end).callCfunction=[template(end).callCfunction,...
                            sprintf('     libHandle = LoadLibrary("%s.dll");\n',...
                                    dynamicLibrary_dlopen)];
        template(end).callCfunction=[template(end).callCfunction,...
                            sprintf('     if (!libHandle) { printf("[%%s] Unable to open library\\n",__FILE__);return; }\n')];
        template(end).callCfunction=[template(end).callCfunction,sprintf('#endif // _WIN32\n')];
        template(end).callCfunction=[template(end).callCfunction,sprintf('  }\n')];
        template(end).callCfunction=[template(end).callCfunction,sprintf('  if (load[0]==0) {\n')];
        template(end).callCfunction=[template(end).callCfunction,sprintf('#ifdef __linux__\n')];
        template(end).callCfunction=[template(end).callCfunction,...
                            sprintf('                  while (!dlclose(libHandle)) printf(".");\n')];
        template(end).callCfunction=[template(end).callCfunction,sprintf('#elif __APPLE__\n')];
        template(end).callCfunction=[template(end).callCfunction,...
                            sprintf('                  while (!dlclose(libHandle)) printf("."); \n')];
        template(end).callCfunction=[template(end).callCfunction,sprintf('#elif _WIN32\n')];
        template(end).callCfunction=[template(end).callCfunction,...
                            sprintf('                  while (FreeLibrary(libHandle)) printf("."); \n')];
        template(end).callCfunction=[template(end).callCfunction,sprintf('#endif // _WIN32\n')];
        template(end).callCfunction=[template(end).callCfunction,...
                            sprintf('                  libHandle = NULL;\n')];
        template(end).callCfunction=[template(end).callCfunction,...
                            sprintf('   }\n')];

        if verboseLevel>3
            template(end).callCfunction=[template(end).callCfunction,sprintf('   printf("%s_load (after):\tlibHandle=%%lx, load=%%lf\\n",libHandle,load[0]);\n',dynamicLibrary)];
        end
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Creates code for one gateway function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function writeGateway(cmexname,Sfunction,Cfunction,...
                      inputs,outputs,sizes,...
                      defines,includes,code,...
                      preprocess,preprocessParameters,...
                      callCfunction,method,...
                      classFolder,fic,callType,callLibrary,compilerOptimization,...
                      dynamicLibrary,templateLoad,...
                      dummySimulinkIOs,...
                      verboseLevel)

    debugCount=0;

    %% class method
    if ~isempty(fic)
        % create 'function' declaration
        if isempty(outputs)
            fprintf(fic,'     function %s(obj',method);
        else
            fprintf(fic,'     function [varargout]=%s(obj',method);
        end
        for i=1:length(inputs)
            fprintf(fic,',%s',inputs(i).name);
        end
        fprintf(fic,')\n');
        for i=1:length(inputs)
            % assign default values to inputs
            if isfield(inputs(i),'default')
                fprintf(fic,'         if nargin<%d\n',i+1);
                fprintf(fic,'           %s=%s([%s]);\n',...
                        inputs(i).name,inputs(i).type,mymat2str(inputs(i).default));
                fprintf(fic,'         end\n');
            end
            if callLibrary
                % check inputs types and size
                fprintf(fic,'         if ~isa(%s,''%s'')\n',inputs(i).name,inputs(i).type);
                fprintf(fic,'           error(''%s: input %s should be of type %s and not %%s\\n'',class(%s))\n',...
                        method,inputs(i).name,inputs(i).type,inputs(i).name);
                fprintf(fic,'         end\n');
                sz=str2double(inputs(i).msizes);
                if ~any(isnan(sz))
                    % method only check sizes if all sizes are numeric
                    fprintf(fic,'         if ~isequal(size(%s),[%s])\n',inputs(i).name,mymat2str(sz));
                    fprintf(fic,'           error(''%s: input %s should have size [%s] and not %%s\\n'',mat2str(size(%s)))\n',...
                            method,inputs(i).name,mymat2str(sz),inputs(i).name);
                    fprintf(fic,'         end\n');
                else
                    error('checking non-numeric sizes not implemented when calling the library directly');
                end
            end
        end
        if callLibrary
            % create outputs
            for i=1:length(outputs)
                sz=str2double(outputs(i).msizes);
                if strcmp(outputs(i).type,'sparse')
                    fprintf(fic,'         %s=sparse([],[],[],%s);\n',outputs(i).name,index2str(sz));
                else
                    fprintf(fic,'         %s=zeros(%s,''%s'');\n',outputs(i).name,index2str(sz),outputs(i).type);
                end
            end
        end
        fprintf(fic,'         ');
        sep='[';
        if callLibrary
            % call lib assumed inputs may actually be outputs passed by reference
            for i=1:length(inputs)
                fprintf(fic,'%c~',sep);
                sep=',';
            end
        end
        for i=1:length(outputs)
            fprintf(fic,'%c%s',sep,outputs(i).name);
            sep=',';
        end
        if sep ~= '['
            fprintf(fic,']=');
        end
        if callLibrary
            fprintf(fic,'calllib(''%s'',''%s''',dynamicLibrary,Cfunction);
            sep=',';
        else
            fprintf(fic,'         %s',cmexname);
                sep='(';
        end
        for i=1:length(inputs)
            fprintf(fic,'%c%s',sep,inputs(i).name);
            sep=',';
        end
        if callLibrary
            for i=1:length(outputs)
                fprintf(fic,'%c%s',sep,outputs(i).name);
                sep=',';
            end
        end
        if sep=='('
            fprintf(fic,'(');
        end
        fprintf(fic,');\n');
        if length(outputs)==1
            fprintf(fic,'         varargout={%s};\n',outputs(1).name);
        elseif length(outputs)>1
            fprintf(fic,'         if nargout==1\n');
            sep='[';
            for i=1:length(outputs)
                fprintf(fic,'           varargout{1}.%s=%s;\n',outputs(i).name,outputs(i).name);
            end
            fprintf(fic,'         else\n');
            fprintf(fic,'           varargout=');
            sep='{';
            for i=1:length(outputs)
                fprintf(fic,'%c%s',sep,outputs(i).name);
                sep=',';
            end
            fprintf(fic,'};\n');
            fprintf(fic,'         end\n');
        end
        fprintf(fic,'     end\n');
    end

    %% Write Gateway header
    if verboseLevel>2
       fprintf('creating cmex function %s.c (%s)\n',cmexname,Cfunction);
    end
    cfilename=fsfullfile(classFolder,sprintf('%s.c',cmexname));
    fid=fopen(cfilename,'w');
    if fid<0
        error('createGateway: Unable to create gateway file ''%s''\n',cfilename);
    end

    %% Write simulink S-function header
    if ~isempty(Sfunction)
        sFname=fsfullfile(classFolder,sprintf('%s.c',Sfunction));
        if verboseLevel>2
            fprintf('creating simulink S-function %s (%s)\n',sFname,Sfunction);
        end
        sfid=fopen(sFname,'w');
        if sfid<0
            error('createGateway: Unable to create gateway file ''%s''\n',sFname);
        end
    else
        sfid=[];
    end
    fids=[fid,sfid];

    %% Write header's

    for f=fids
        fprintf(f,'/* Created by script createGateway.m on %s */\n\n',datestr(now));
        includeFile(f,'COPYRIGHT.c');
    end
    [cmd,scripts]=gatewayCompile(compilerOptimization,classFolder,...
                                 fsfullfile(classFolder,cmexname),verboseLevel);
    fprintf(fid,'/* %s */\n\n',cmd);

    for f=fids
        %fprintf(f,'#include <math.>"\n');
        if ismember(callType,{'dynamicLibrary'})
            fprintf(f,'#ifdef __linux__\n#include <dlfcn.h>\n#include <unistd.h>\n#endif\n');
            fprintf(f,'#ifdef __APPLE__\n#include <dlfcn.h>\n#include <unistd.h>\n#endif\n');
            fprintf(f,'#ifdef _WIN32\n#include <windows.h>\n#include <stdint.h>\n#endif\n');
        end
        %fprintf(f,'#include <string.h>\n');
        %fprintf(f,'#include <stdint.h>\n');
        %fprintf(f,'#include <stdlib.h>\n');
        %fprintf(f,'#include <pthread.h>\n');
        fprintf(f,'#include <fcntl.h>\n');
        fprintf(f,'#include <inttypes.h>\n');
        fprintf(f,'#include <mex.h>\n\n');
    end

    % defines
    for f=fids
        if ~isempty(defines)
            names=fields(defines);
            for j=1:length(names)
                value=getfield(defines,names{j});
                if ischar(value)
                    fprintf(f,'#define %s %s\n',names{j},value);
                elseif isnumeric(value) && length(value)==1
                    fprintf(f,'#define %s %g\n',names{j},value);
                    printf('#define %s %g\n',names{j},value);
                else
                    value
                    error('define %s has invalid value\n',names{j});
                end
            end
            fprintf(f,'\n');
        end

        switch callType
          case 'include'
            % declare function that does work
            fprintf(f,'extern void %s(\n%s);\n\n',...
                    Cfunction,declareArguments4Cfunction(inputs,outputs,sizes));
          case 'dynamicLibrary'
            % declare pointer to function that does the work
            fprintf(f,'#ifdef __linux__\nvoid *libHandle=NULL;\n#endif\n');
            fprintf(f,'#ifdef __APPLE__\nvoid *libHandle=NULL;\n#endif\n');
            fprintf(f,'#ifdef _WIN32\nHMODULE libHandle=NULL;\n#endif\n');
            if ~isempty(Cfunction)
                fprintf(f,'void (*P%s)(\n%s)=NULL;\n\n',...
                        Cfunction,declareArguments4Cfunction(inputs,outputs,sizes));
            end
          case 'client-server'
            ph=fileparts(which('createGateway'));
            fprintf(f,'#include "%s"\n',fsfullfile(ph,'client.c'));
        end
    end

    %% Execute preprocess & add includes & code

    if verboseLevel>1
        fprintf('executing preprocess()... ');
        t1=clock;
    end
    if ~isempty(preprocess)
        fclose(fid); % close file so that preprocess function can append it
        %% run preprocess function
        fpre=fopen('tmp_toremove.m','w');
        fwrite(fpre,preprocess);
        fclose(fpre);
        rehash path;
        feval('tmp_toremove',preprocessParameters{:});
        fid=fopen(fsfullfile(classFolder,sprintf('%s.c',cmexname)),'a'); % reopen file
    end
    if verboseLevel>1
        fprintf('done preprocess() (%.2f sec) ',etime(clock,t1));
    end

    for f=fids
        if size(includes,1)>0
            fprintf(f,'#include "%s"\n',includes{:});
            fprintf(f,'\n');
        end

        if ~isempty(code)
            fprintf(f,'%s\n',code);
        end
    end

    %% Create initializations for S-function

    if ~isempty(sfid)
        fprintf(sfid,'#define S_FUNCTION_NAME %s\n',Sfunction);
        fprintf(sfid,'#define S_FUNCTION_LEVEL 2\n');
        fprintf(sfid,'#include "simstruc.h"\n');
        fprintf(sfid,'#define NUM_PARAMS (0)\n\n');

        % mdlInitializeSizes
        fprintf(sfid,'static void mdlInitializeSizes(SimStruct *S) {\n');
        fprintf(sfid,'   ssSetNumSFcnParams(S, 0);\n');

        fprintf(sfid,'   if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;\n');


        fprintf(sfid,'\n   /* Process inputs */\n');
        fprintf(sfid,'   if (!ssSetNumInputPorts(S,%d)) return;\n',...
                length(inputs)+dummySimulinkIOs);
        for i=1:length(inputs)
            sz=str2double(inputs(i).msizes);
            if any(isnan(sz))
                warning('Creation of Simulink S-function only supports fixed sizes, ''%s'' found for input %d\n',index2str(sz),i);
            end
            %fprintf(sfid,'   ssSetInputPortWidth(S,%d,%d);\n',i-1,sz);
            fprintf(sfid,' { DECL_AND_INIT_DIMSINFO(di);\n');
            fprintf(sfid,'   int_T dims[]={%s};\n',index2str(sz));
            fprintf(sfid,'   di.numDims = %d;\n',length(sz));
            fprintf(sfid,'   di.dims = dims;\n');
            fprintf(sfid,'   di.width = %d;\n',prod(sz));
            fprintf(sfid,'   ssSetInputPortDimensionInfo(S,%d,&di); }\n',i-1);
            fprintf(sfid,'   ssSetInputPortDataType(S,%d,%s);\n',i-1,matlab2sstype(inputs(i).type));
            fprintf(sfid,'   ssSetInputPortRequiredContiguous(S,%d,1);\n',i-1);
            fprintf(sfid,'   ssSetInputPortDirectFeedThrough(S,%d,1);\n',i-1);
        end
        if dummySimulinkIOs
            fprintf(sfid,'   ssSetInputPortWidth(S,%d,1);\n',length(inputs));
            fprintf(sfid,'   ssSetInputPortDirectFeedThrough(S,%d,1);\n',length(inputs));
        end

        fprintf(sfid,'\n   /* Process outputs */\n');
        fprintf(sfid,'   if (!ssSetNumOutputPorts(S,%d)) return;\n',...
                length(outputs)+dummySimulinkIOs);
        for i=1:length(outputs)
            sz=str2double(outputs(i).msizes);
            if any(isnan(sz))
                warning('Creation of Simulink S-function only supports fixed sizes, ''%s'' found for output %d\n',index2str(sz),i);
            end
            %fprintf(sfid,'   ssSetOutputPortWidth(S,%d,%s);\n',i-1,sz);
            fprintf(sfid,' { DECL_AND_INIT_DIMSINFO(di);\n');
            fprintf(sfid,'   int_T dims[]={%s};\n',index2str(sz));
            fprintf(sfid,'   di.numDims = %d;\n',length(sz));
            fprintf(sfid,'   di.dims = dims;\n');
            fprintf(sfid,'   di.width = %d;\n',prod(sz));
            fprintf(sfid,'   ssSetOutputPortDimensionInfo(S,%d,&di); }\n',i-1);
            fprintf(sfid,'   ssSetOutputPortDataType(S,%d,%s);\n',i-1,matlab2sstype(outputs(i).type));
        end
        if dummySimulinkIOs
            fprintf(sfid,'   ssSetOutputPortWidth(S,%d,1);\n',length(outputs));
        end

        fprintf(sfid,'\n   ssSetNumSampleTimes(S, 1);\n\n');
        fprintf(sfid,'   ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE|SS_OPTION_CALL_TERMINATE_ON_EXIT);\n');

        fprintf(sfid,'}\n\n');

        % mdlInitializeSampleTimes
        fprintf(sfid,'static void mdlInitializeSampleTimes(SimStruct *S) {\n');
        fprintf(sfid,'   ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);\n');
        fprintf(sfid,'   ssSetOffsetTime(S, 0, 0.0);\n');
        fprintf(sfid,'}\n\n');

        % mdlTerminate
        fprintf(sfid,'static void mdlTerminate(SimStruct *S) {\n');
        if ismember(callType,{'dynamicLibrary'})
            %    fprintf(sfid,'   { int load[]={0};\n%s\n   }\n',templateLoad.callCfunction);
            fprintf(sfid,'#ifdef __linux__\n');
            fprintf(sfid,'                  while (!dlclose(libHandle)) printf(".");\n');
            fprintf(sfid,'#elif __APPLE__\n');
            fprintf(sfid,'                  while (!dlclose(libHandle)) printf(".");\n');
            fprintf(sfid,'#elif _WIN32\n');
            fprintf(sfid,'                  while (!FreeLibrary(libHandle)) printf("."); \n');
            fprintf(sfid,'#endif // _WIN32\n');
            fprintf(sfid,'   libHandle=NULL;\n');
            fprintf(sfid,'   P%s=NULL;\n',Cfunction);
        end
        fprintf(sfid,'}\n\n');

    end

    %% Check and process arguments for mdlOutputs for S-function

    if ~isempty(sfid)
        fprintf(sfid,'static void mdlOutputs(SimStruct *S, int_T tid)\n{\n');

        fprintf(sfid,'   /* Process inputs */\n');
        for i=1:length(inputs)
            fprintf(sfid,'   const %s *%s = ssGetInputPortSignal(S,%d);\n',...
                    matlab2Ctype(inputs(i).type),inputs(i).name,i-1);
        end
        if dummySimulinkIOs
            fprintf(sfid,'   const double *dummyIn = ssGetInputPortSignal(S,%d);\n',length(inputs));
        end
        fprintf(sfid,'   /* Process outputs */\n');
        for i=1:length(outputs)
            fprintf(sfid,'   %s *%s = ssGetOutputPortSignal(S,%d);\n',...
                    matlab2Ctype(outputs(i).type),outputs(i).name,i-1);
        end
        if dummySimulinkIOs
            fprintf(sfid,'   double *dummyOut = ssGetOutputPortSignal(S,%d);\n',length(outputs));
        end
    end

    %% Check and process arguments for MEX gateways

    % gateway header
    fprintf(fid,'void mexFunction( int nlhs, mxArray *plhs[],\n');
    fprintf(fid,'                  int nrhs, const mxArray *prhs[])\n');
    fprintf(fid,'{\n%s',declareVariables(inputs,outputs,sizes));

    % fprintf(fid,'mexPrintf("debug at %d\\n");\n',debugCount);debugCount=debugCount+1;

    fprintf(fid,'\n   /* Process inputs */\n\n');

    % check # of inputs
    fprintf(fid,'   /* Check # inputs */\n');
    fprintf(fid,'   if(nrhs!=%d) {\n',length(inputs));
    fprintf(fid,'      mexErrMsgIdAndTxt("%s:nrhs", "%d inputs required, %%d found.",nrhs);\n',...
            cmexname,length(inputs));
    fprintf(fid,'      return; }\n\n');

    toAssign=sizes;
    for i=1:length(inputs)
        % fprintf(fid,'mexPrintf("debug at %d\\n");\n',debugCount);debugCount=debugCount+1;

        if 0
           fprintf('   input %s, type %s\n',inputs(i).name,inputs(i).type);
        end
        fprintf(fid,'   /* input %s */\n',inputs(i).name);
        fprintf(fid,'   if (mxGetNumberOfDimensions(prhs[%d])!=%d)\n',...
                i-1,length(inputs(i).msizes));
        fprintf(fid,'       mexErrMsgIdAndTxt("%s:prhs","input %d (%s) should have %d dimensions, %%d found.",mxGetNumberOfDimensions(prhs[%d]));\n',...
                        cmexname,i,inputs(i).name,length(inputs(i).msizes),i-1);
        fprintf(fid,'   { const mwSize *dims=mxGetDimensions(prhs[%d]);\n',i-1);
        for j=1:length(inputs(i).msizes)
            k=find(strcmp(inputs(i).msizes{j},toAssign));
            toAssign(k)=[];
            if  ~strcmp(inputs(i).msizes{j},'~')
                if isempty(k)
                    % already assigned size, test if compatible
                    fprintf(fid,'   if (dims[%d]!=%s)\n',j-1,inputs(i).msizes{j});
                    fprintf(fid,'       mexErrMsgIdAndTxt("%s:prhs","input %d (%s) should have %%d (=%s) in dimension %d, %%d found.",%s,dims[%d]);\n',...
                            cmexname,i,inputs(i).name,...
                            inputs(i).msizes{j},j,inputs(i).msizes{j},j-1);
                else
                    % assign size
                    fprintf(fid,'   %s=dims[%d];\n',inputs(i).msizes{j},j-1);
                end
            end
        end
        fprintf(fid,'   }\n');
        % fprintf(fid,'mexPrintf("debug at %d\\n");\n',debugCount);debugCount=debugCount+1;
        % check its full
        fprintf(fid,'   if (mxIsSparse(prhs[%d]))\n',i-1);
        fprintf(fid,'       mexErrMsgIdAndTxt("%s:prhs","input %d (%s) cannot be sparse (use full())");\n',...
                cmexname,i,inputs(i).name);
        % check type
        fprintf(fid,'   if (!%s(prhs[%d]))\n',matlab2CtypeTest(inputs(i).type),i-1);
        fprintf(fid,'       mexErrMsgIdAndTxt("%s:prhs","input %d (%s) should have type %s");\n',...
                cmexname,i,inputs(i).name,inputs(i).type);
        % fprintf(fid,'mexPrintf("debug at %d\\n");\n',debugCount);debugCount=debugCount+1;
        % get pointer
        if strcmp(inputs(i).type,'char')
            fprintf(fid,'   %s=mxArrayToString(prhs[%d]);\n',inputs(i).name,i-1);
        else
            fprintf(fid,'   %s=mxGetData(prhs[%d]);\n',inputs(i).name,i-1);
        end
    end

    % fprintf(fid,'mexPrintf("debug at %d\\n");\n',debugCount);debugCount=debugCount+1;

    fprintf(fid,'\n   /* Process outputs */\n\n');
    fprintf(fid,'   /* Check # outputs */\n');
    fprintf(fid,'   if(nlhs!=%d) {\n',length(outputs));
    fprintf(fid,'      mexErrMsgIdAndTxt("%s:nrhs", "%d outputs required, %%d found.",nlhs);\n',...
            cmexname,length(outputs));
    fprintf(fid,'      return; }\n\n');

    for i=1:length(outputs)
        % fprintf(fid,'mexPrintf("debug at %d\\n");\n',debugCount);debugCount=debugCount+1;

        if 0
            fprintf('   output %s, type %s\n',outputs(i).name,outputs(i).type);
        end
        fprintf(fid,'   /* output %s */\n',outputs(i).name);
        if length(outputs(i).sizes)~=1 || ~strcmp(outputs(i).sizes{1},'~')
            if strcmp(outputs(i).type,'sparse')
                fprintf(fid,'     %s=plhs[%d] = mxCreateSparse(%s,%s,0,mxREAL);\n',...
                        outputs(i).name,i-1,outputs(i).msizes{1},outputs(i).msizes{2});
            else
                fprintf(fid,'   { mwSize dims[]={');
                fprintf(fid,'%s,',outputs(i).msizes{1:end-1});
                fprintf(fid,'%s};\n',outputs(i).msizes{end});
                fprintf(fid,'     plhs[%d] = mxCreateNumericArray(%d,dims,%s,mxREAL);\n',...
                        i-1,length(outputs(i).msizes),matlab2classid(outputs(i).type));
                fprintf(fid,'     %s=mxGetData(plhs[%d]); }\n',outputs(i).name,i-1);
            end
        else
            % size == '~'
            fprintf(fid,'   %s=plhs+%d;\n',outputs(i).name,i-1);
        end
    end

    %% Write code to call the C function

    for f=fids
        fprintf(f,'\n   /* Call function */\n');
        fprintf(f,'%s',callCfunction);
    end

    % close gateway function
    fprintf(fid,'}\n');
    fclose(fid);

    % close S-function
    if ~isempty(sfid)
        if dummySimulinkIOs
            fprintf(sfid,'   *dummyOut = *dummyIn;\n\n');
        end
        fprintf(sfid,'} // mdlOutputs()\n\n');

        fprintf(sfid,'#ifdef MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */\n');
        fprintf(sfid,'#include "simulink.c"     /* MEX-file interface mechanism */\n');
        fprintf(sfid,'#else\n');
        fprintf(sfid,'#include "cg_sfun.h"      /* Code generation registration function */\n');
        fprintf(sfid,'#endif\n');
        fclose(sfid);
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Auxiliary functions to construct C declarations of inputs & outputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str=declareVariables(inputs,outputs,sizes)
% Returns string with the typed-arguments for the Cfunction,
% constructed from the inputs & outputs

    str='';
    if length(inputs)>0
        str=[str,sprintf('   /* inputs */\n')];
        for i=1:length(inputs)
            str=[str,sprintf('   const %s *%s;\n',matlab2Ctype(inputs(i).type),inputs(i).name)];
        end
    end
    if length(outputs)>0
        str=[str,sprintf('   /* outputs */\n')];
        for i=1:length(outputs)
            if length(outputs(i).sizes)~=1 || ~strcmp(outputs(i).sizes{1},'~')
                str=[str,sprintf('   %s *%s;\n',...
                                 matlab2Ctype(outputs(i).type),outputs(i).name)];
            else
                str=[str,sprintf('   mxArray **%s;\n',outputs(i).name)];
            end
        end
    end
    if length(sizes)>0
        str=[str,sprintf('   /* sizes */\n')];
        str=[str,sprintf('   mwSize %s;\n',sizes{:})];
    end
end

function str=declareArguments4Cfunction(inputs,outputs,sizes)
% Returns string with the typed-arguments for the Cfunction,
% constructed from the inputs & outputs

    str=declareVariables(inputs,outputs,sizes);
    % ';' -> ','
    str=regexprep(str,';',',');
    % remove trailing ','
    str=regexprep(str,',\n$','');

end

function str=callArguments4Cfunction(inputs,outputs,sizes)
% Returns string with the (untyped) arguments for the Cfunction,
% constructed from the inputs & outputs

    str=sprintf('%s,',inputs(:).name);
    str=[str,sprintf('%s,',outputs(:).name)];
    str=[str,sprintf('%s,',sizes{:})];
    if ~isempty(str) && str(end)==','
        str(end)=[];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Auxiliary functions to read template
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [wholeline,linenum]=getLine(fcmext,linenum)
% Read line discarding leading white spaces and trailing white spaces and comments
    wholeline='';
    openComment=false;
    while isempty(wholeline);
        linenum=linenum+1;
        wholeline=fgetl(fcmext);
        if ~ischar(wholeline)
            wholeline ='';
            return;
        end
        [wholeline,openComment]=cleanupLine(wholeline,openComment);
    end
end

function [wholeline,openComment]=cleanupLine(wholeline,openComment)

    %fprintf('  "%s"',wholeline);

    if openComment
        % end of comment
        if ~isempty(regexp(wholeline,'\*/'))
            wholeline=regexprep(wholeline,'.*/*/','');
            openComment=false;
        else
            wholeline='';
        end
    else
        % remove /* ... */ comment
        wholeline=regexprep(wholeline,'/\*.+\*/','');

        % remove leading white spaces
        wholeline=regexprep(wholeline,'^\s*','');

        % remove trailing % or // comment
        wholeline=regexprep(wholeline,'(%|//).*$','');

        % remove trailing white spaces
        wholeline=regexprep(wholeline,'\s*$','');

        % start of comment
        if ~isempty(regexp(wholeline,'/\*'))
            wholeline=regexprep(wholeline,'/\*.*','');
            openComment=true;
        end
    end
    %fprintf('->"%s"\n',wholeline);
end

function [obj,nextline,linenum]=readVariables(fcmext,linenum,obj)
    while 1
        [nextline,linenum]=getLine(fcmext,linenum);
        %fprintf('  %d> "%s"\n',linenum,nextline);
        S=regexp(nextline,'^(\w+)\s+(\w+)\s*\[([\w,~-+*]+)\]$','tokens');
        if ~isempty(S) && length(S{1})==3
            obj(end+1).type=S{1}{1};
            obj(end).name=S{1}{2};
            obj(end).sizes=strsplit(S{1}{3},',');
        else
            return;
        end
    end
end

function [preprocess,nextline,linenum]=readPreprocess(fcmext,linenum,args);

    preprocess=sprintf('(%s)\n',args);

    openComment=false;
    while 1
        linenum=linenum+1;
        nextline=fgetl(fcmext);
        if ~ischar(nextline)
            nextline='';
            return;
        end
        if ~isempty(regexp(nextline,'^(#endif\s*$|\s*function\s+)','start'))
            [nextline,openComment]=cleanupLine(nextline,openComment);
            return;
        else
            preprocess=[preprocess,sprintf('%s\n',nextline)];
        end
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Auxiliary functions to convert types
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Convert a matlab type to a c type
function str=matlab2Ctype(str)

    switch (str)
      case {'uint8','uint16','uint32','uint64','int8','int16','int32','int64'}
        str=sprintf('%s_t',str);
      case {'sparse'}
        str='mxArray';
      case {'double','single','char'}
      otherwise
        error('createGateway: unknown type %s\n',str);
    end
end

%% Returns the name of the C mx function that tests for a desired matlab
function str=matlab2CtypeTest(str)

    switch (str)
      case 'char'
        str='mxIsChar';
      case 'uint8'
        str='mxIsUint8';
      case 'uint16'
        str='mxIsUint16';
      case 'uint32'
        str='mxIsUint32';
      case 'uint64'
        str='mxIsUint64';
      case 'int8'
        str='mxIsInt8';
      case 'int16'
        str='mxIsInt16';
      case 'int32'
        str='mxIsInt32';
      case 'int64'
        str='mxIsInt64';
      case 'double'
        str='mxIsDouble';
      case 'single'
        str='mxIsSingle';
      otherwise
        error('createGateway: unknown type %s\n',str);
    end
end

%% Convert a matlab type to a mex class id
function str=matlab2classid(str)

    switch (str)
      case 'uint8'
        str='mxUINT8_CLASS';
      case 'uint16'
        str='mxUINT16_CLASS';
      case 'uint32'
        str='mxUINT32_CLASS';
      case 'uint64'
        str='mxUINT64_CLASS';
      case 'int8'
        str='mxINT8_CLASS';
      case 'int16'
        str='mxINT16_CLASS';
      case 'int32'
        str='mxINT32_CLASS';
      case 'int64'
        str='mxINT64_CLASS';
      case 'double'
        str='mxDOUBLE_CLASS';
      case 'single'
        str='mxSINGLE_CLASS';
      otherwise
        error('createGateway: unknown type %s\n',str);
    end
end

%% Convert a matlab type to an S-function data type ID
function str=matlab2sstype(str)

    switch (str)
      case 'uint8'
        str='SS_UINT8';
      case 'uint16'
        str='SS_UINT16';
      case 'uint32'
        str='SS_UINT32';
      case 'uint64'
        str='SS_UINT64';
      case 'int8'
        str='SS_INT8';
      case 'int16'
        str='SS_INT16';
      case 'int32'
        str='SS_INT32';
      case 'int64'
        str='SS_INT64';
      case 'double'
        str='SS_DOUBLE';
      case 'single'
        str='SS_SINGLE';
      otherwise
        error('createGateway: unknown type %s\n',str);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Auxiliary functions to perform compilations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function includeFile(fid,filename,commentFormat)
% includeFile(fid,filename)
%   includes the file named 'filename' into the file with the given
%   descriptor
    if nargin<3
        commentFormat='/* %s */';
    end

    fii=fopen(filename,'r');
    if fii<0
        error('unable to open file ''%s''\n',filename);
    end
    if ~isempty(commentFormat)
        fprintf(fid,[commentFormat,'\n'],sprintf('START OF #included "%s"',filename));
    end
    a=fread(fii,inf);
    fwrite(fid,a);
    if ~isempty(commentFormat)
        fprintf(fid,[commentFormat,'\n'],sprintf('END OF #included "%s"',filename));
    end
    fclose(fii);

end
