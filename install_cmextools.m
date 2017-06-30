fprintf('Seeting up path...');
home=[fileparts(which('install_cmextools')),'/lib'];
folders={home};

s=path;
old=regexp(s,'[^:]*cmextools[^:]*','match');
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

fprintf('done!\n');