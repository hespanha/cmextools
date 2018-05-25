fprintf('Seeting up path...');
home=[fileparts(which('install_cmextools')),'/lib'];
folders={home};

s=path;
if ispc
    old=regexp(s,'[^;]*cmextools.lib[^/;]*','match');
else
    old=regexp(s,'[^:]*cmextools.lib[^/:]*','match');
end
if ~isempty(old)
    fprintf('removing from path:\n');
    disp(old')
    rmpath(old{:})
end

fprintf('adding to path:\n');
addpath(folders{:});
disp(folders)

fprintf('saving path...');
try
    savepath;
catch me
    fprintf('ATTENTION: unable to save path, add following strings to the matlab path:');
    disp(folders)
    rethrow(me)
end

if ispc
    fprintf('Looking for compiler');
    cmp=mex.getCompilerConfigurations('C','Selected');
    cmd_shell=cmp.Details.CommandLineShell;
    cmd_shellArg=cmp.Details.CommandLineShellArg;
end

fprintf('done!\n');