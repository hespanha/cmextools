
fprintf('Seeting up path...');
home=[fileparts(which('install_cmextools')),'/lib'];
fprintf('removing old...');
rmpath(home);
fprintf('adding new...');
addpath(home);
try
    savepath;
catch me
    fprintf('ATTENTION: unable to save path, add following string to the matlab path:\n%s\n',home);
    rethrow
end
fprintf('done!\n');