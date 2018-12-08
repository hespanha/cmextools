fprintf('Seeting up path:\n');
home=[fileparts(which('install_cmextools')),'/lib'];
folders={home};

s=path;
if ispc
    old=regexp(s,'[^;]*cmextools.lib[^/;]*','match');
else
    old=regexp(s,'[^:]*cmextools.lib[^/:]*','match');
end
if ~isempty(old)
    fprintf('  removing from path:\n');
    disp(old')
    rmpath(old{:})
end

fprintf('  adding to path:\n');
addpath(folders{:});
disp(folders)

fprintf('  saving path...');
try
    savepath;
catch me
    fprintf('ATTENTION: unable to save path. This was probably caused because of insufficient permissions. Either change the permissions of your ''matlabroot'' folder or add following strings to the matlab path:');
    disp(folders)
    rethrow(me)
end
fprintf('done with path!\n\n');

if ispc
    fprintf('Looking for compiler:\n');
    if ispc
        cmd='cl.exe';
    else
        cmd='gcc';
    end
    system_path(cmd);
end
fprintf('done!\n');
