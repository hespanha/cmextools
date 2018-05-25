function rc=system_path(cmd)
% Call C compiler (making sure the path works)

if ispc
    % call batch file that fixes the path
    pth=fileparts(which('libraryCompile'));
    pth=strrep(pth,'\','/');
    cmp=mex.getCompilerConfigurations('C','Selected');
    shell=cmp.Details.CommandLineShell;
    shell=strrep(shell,'\','/');
    shellArg=cmp.Details.CommandLineShellArg;
    setpth=sprintf('"%s" %s',shell,shellArg);
    cmd=['call "',pth,'/system_path.bat" ',setpth,' ',cmd];
    rc=system(cmd);
else
    rc=system(cmd);
end
