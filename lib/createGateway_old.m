function createGateway_old(cmexname,standalone)
% createGateway(cmexname)
%
% Creates a gateway cmex function based on a template in the given cmexname.
% Templates are of the form:
%
% #ifdef createGateway
% function mytimes
%
% inputs
% 	double X1 [m,k]
% 	uint32 S1 [1]
% 	double X2 [k,n]
% 	uint32 S2 [1]
%
% outputs
% 	double Y [m,n]
% #endif
%
% The initial #ifdef anbd final #endif are optional. When present,
% only the portion of the file between these commands is processed,
% otherwise the whole file is processed.
%
% Copyright (C) 2013-16  Joao Hespanha

% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions
% are met:
%    * Redistributions of source code must retain the above copyright
%    notice, this list of conditions and the following disclaimer.
%
%    * Redistributions in binary form must reproduce the above
%    copyright notice, this list of conditions and the following
%    disclaimer in the documentation and/or other materials provided
%    with the distribution.
%
%    * Neither the name of the <ORGANIZATION> nor the names of its
%    contributors may be used to endorse or promote products derived
%    from this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
% FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
% COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
% INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
% BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
% LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
% ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

    fcmext=fopen(cmexname);

    if nargin<2
        standalone=0;
    end

    linenum=0;
    gatewayName='';
    where='';
    start=1;
    while 1
        [s1,s2,s3,wholeline,linenum]=getLine(fcmext,linenum);
        if isempty(s1)
            if ~isempty(gatewayName)
                printGateway(gatewayName,inputs,outputs,sizes,standalone);
            end
            break
        end

        if ~strcmp(s1,'#ifdef') || ~strcmp(s2,'createGateway')
            start=0;
            if isempty(gatewayName) && ~strcmp(s1,'function')
                error('createGateway: ''function'' keyword expected in line %d (''%s'' found)\n',...
                      linenum,s1);
            end
        end

        switch s1
          case '#ifdef'
            if strcmp(s2,'createGateway')
                partial=1;
                if ~start
                    error('createGateway: ''#ifdef creategateway'' in line %d, not at the start of the filexs\n',linenum);
                end
            else
                error('createGateway: ''unexpected ''#ifdef'' in line %d\n',linenum);
            end

          case '#endif'
            if partial
               printGateway(gatewayName,inputs,outputs,sizes,standalone);
               break
            end
            error('createGateway: ''#endif'' without ''#ifdef creategateway'' in line %d\n',...
                  linenum);

          case 'function'
            if ~isempty(gatewayName)
                printGateway(gatewayName,inputs,outputs,sizes,standalone);
            end

            if isempty(s2)
                error('createGateway: empty function name\n');
            end

            gatewayName=s2;
            inputs={};
            outputs={};
            sizes={};
            where='';

          case 'inputs'
            where='inputs';

          case 'outputs'
            where='outputs';

          otherwise
            if isempty(s2) || isempty(s3)
                error('createGateway: unexpected command in line %d (%s)\n',linenum,wholeline);
            end
            if strcmp(where,'inputs')
                inputs{end+1}.type=s1;
                inputs{end}.name=s2;
                inputs{end}.sizes=s3;
            elseif strcmp(where,'outputs')
                outputs{end+1}.type=s1;
                outputs{end}.name=s2;
                outputs{end}.sizes=s3;
            end
        end

    end
    fclose(fcmext);
end

function printGateway(cmexname,inputs,outputs,sizes,standalone)

    debugCount=0;

    if 0
       fprintf('creating function %s\n',cmexname);
    end
    fid=fopen(sprintf('%s.c',cmexname),'w');

    fprintf(fid,'/* mex -largeArrayDims COPTIMFLAGS="-Ofast -DNDEBUG" CFLAGS="\\$CFLAGS -Wall" %s.c */\n\n',cmexname);

    fprintf(fid,'#include "mex.h"\n#include "math.h"\n');
    fprintf(fid,'#include <string.h>\n#include <stdint.h>\n#include <stdlib.h>\n#include <fcntl.h>\n#include <unistd.h>\n#include <pthread.h>\n\n');

    % determine "size" variables
    sizes={};
    for i=1:length(inputs)
        for j=1:length(inputs{i}.sizes)
            if isnan(str2double(inputs{i}.sizes{j}))
                if ~any(strcmp(inputs{i}.sizes{j},sizes))
                    sizes{end+1}=inputs{i}.sizes{j};
                end
            end
        end
    end

    % declare function that does work
    fprintf(fid,'extern void %s_raw(\n',cmexname);
    if length(inputs)>0
        fprintf(fid,'   /* inputs */');
    end
    comma='';
    for i=1:length(inputs)
        fprintf(fid,'%c\n   %s *%s',comma,matlab2Ctype(inputs{i}.type),inputs{i}.name);
        comma=',';
    end
    if length(outputs)>0
        fprintf(fid,'\n   /* outputs */');
    end
    for i=1:length(outputs)
        fprintf(fid,'%c\n   %s *%s',comma,matlab2Ctype(outputs{i}.type),outputs{i}.name);
        comma=',';
    end
    if length(sizes)>0
        fprintf(fid,'\n   /* sizes */');
    end
    for i=1:length(sizes)
        fprintf(fid,'%c\n   mwSize %s',comma,sizes{i});
        comma=',';
    end
    fprintf(fid,');\n\n');

    % gateway header
    fprintf(fid,'void mexFunction( int nlhs, mxArray *plhs[],\n');
    fprintf(fid,'                  int nrhs, const mxArray *prhs[])\n');
    fprintf(fid,'{\n');

    % declare variables
    fprintf(fid,'   /* inputs */\n');
    for i=1:length(inputs)
        fprintf(fid,'   %s *%s;\n',matlab2Ctype(inputs{i}.type),inputs{i}.name);
    end
    if length(outputs)>0
        fprintf(fid,'   /* outputs */\n');
    end
    for i=1:length(outputs)
        fprintf(fid,'   %s *%s;\n',matlab2Ctype(outputs{i}.type),outputs{i}.name);
    end
    fprintf(fid,'   /* sizes */\n');
    for i=1:length(sizes)
        fprintf(fid,'   mwSize %s;\n',sizes{i});
    end

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
           fprintf('   input %s, type %s\n',inputs{i}.name,inputs{i}.type);
        end
        fprintf(fid,'   /* input %s */\n',inputs{i}.name);
        % padd sizes to 2
        while length(inputs{i}.sizes)<2
            inputs{i}.sizes{end+1}='1';
        end
        switch length(inputs{i}.sizes)
          case 2,
            k=find(strcmp(inputs{i}.sizes{1},toAssign));
            toAssign(k)=[];
            if isempty(k)
                % already assigned size, test if compatible
                fprintf(fid,'   if (mxGetM(prhs[%d])!=%s)\n',i-1,inputs{i}.sizes{1});
                fprintf(fid,'       mexErrMsgIdAndTxt("%s:prhs","input %d (%s) should have %%d (=%s) rows, %%d found.",%s,mxGetM(prhs[%d]));\n',...
                        cmexname,i,inputs{i}.name,inputs{i}.sizes{1},inputs{i}.sizes{1},i-1);
            else
                % assign size
                fprintf(fid,'   %s=mxGetM(prhs[%d]);\n',inputs{i}.sizes{1},i-1);
            end
            k=find(strcmp(inputs{i}.sizes{2},toAssign));
            toAssign(k)=[];
            if isempty(k)
                % already assigned size, test if compatible
                fprintf(fid,'   if (mxGetN(prhs[%d])!=%s)\n',i-1,inputs{i}.sizes{2});
                fprintf(fid,'       mexErrMsgIdAndTxt("%s:prhs","input %d (%s) should have %%d (=%s) cols, %%d found.",%s,mxGetN(prhs[%d]));\n',...
                        cmexname,i,inputs{i}.name,inputs{i}.sizes{2},inputs{i}.sizes{2},i-1);
            else
                % assign size
                fprintf(fid,'   %s=mxGetN(prhs[%d]);\n',inputs{i}.sizes{2},i-1);
            end
          otherwise
            error('createGateway: inputs array of dimension %d not implemented\n');
        end
        % fprintf(fid,'mexPrintf("debug at %d\\n");\n',debugCount);debugCount=debugCount+1;
        % check type
        fprintf(fid,'   if (!%s(prhs[%d]))\n',matlab2CtypeTest(inputs{i}.type),i-1);
        fprintf(fid,'       mexErrMsgIdAndTxt("%s:prhs","input %d (%s) should have type %s");\n',...
                cmexname,i,inputs{i}.name,inputs{i}.type);
        % fprintf(fid,'mexPrintf("debug at %d\\n");\n',debugCount);debugCount=debugCount+1;
        % get pointer
        fprintf(fid,'   %s=mxGetData(prhs[%d]);\n',inputs{i}.name,i-1);
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
            fprintf('   output %s, type %s\n',outputs{i}.name,outputs{i}.type);
        end

        fprintf(fid,'   /* output %s */\n',outputs{i}.name);
        % padd sizes to 2
        while length(outputs{i}.sizes)<2
            outputs{i}.sizes{end+1}='1';
        end
        fprintf(fid,'   { mwSize dims[]={');
        fprintf(fid,'%s,',outputs{i}.sizes{1:end-1});
        fprintf(fid,'%s};\n',outputs{i}.sizes{end});
        fprintf(fid,'     plhs[%d] = mxCreateNumericArray(%d,dims,%s,mxREAL);\n',...
                i-1,length(outputs{i}.sizes),matlab2classid(outputs{i}.type));
        fprintf(fid,'     %s=mxGetData(plhs[%d]); }\n',outputs{i}.name,i-1);
    end


    if standalone==0
        % call function that does work
        fprintf(fid,'\n   /* Call function */\n');
        fprintf(fid,'   %s_raw(',cmexname);
        comma='';
        for i=1:length(inputs)
            fprintf(fid,'%c%s',comma,inputs{i}.name);
            comma=', ';
        end
        for i=1:length(outputs)
            fprintf(fid,'%c%s',comma,outputs{i}.name);
            comma=', ';
        end
        for i=1:length(sizes)
            fprintf(fid,'%c%s',comma,sizes{i});
            comma=', ';
        end
        fprintf(fid,');\n');

        % close gateway function
        fprintf(fid,'}\n');

        fprintf(fid,'\n#include "%s_raw.c"\n',cmexname);
    else
        % save data to file
        fprintf(fid,'\n   /* Save data to file */\n');
        fprintf(fid,' { int fid=open("%s.bin",O_CREAT|O_TRUNC|O_WRONLY,S_IRUSR|S_IWUSR);\n',cmexname);
        fprintf(fid,'   /* inputs */\n');
        for i=1:length(inputs)
            switch length(inputs{i}.sizes)
              case 2,
                fprintf(fid,'    { mwSize sz; sz=sizeof(%s)*mxGetM(prhs[%d])*mxGetN(prhs[%d]);\n',...
                        matlab2Ctype(inputs{i}.type),i-1,i-1);
                fprintf(fid,'      write(fid,&sz,sizeof(sz));\n');
                %fprintf(fid,'      mexPrintf("writing %s (%%lu bytes)\\n",sz);\n',inputs{i}.name);
                fprintf(fid,'      write(fid,%s,sz); }\n',inputs{i}.name);
              otherwise
                error('createGateway: inputs array of dimension %d not implemented\n');
            end
        end
        if length(outputs)>0
            fprintf(fid,'   /* outputs'' sizes */\n');
        end
        for i=1:length(outputs)
            switch length(outputs{i}.sizes)
              case 2,
                fprintf(fid,'    { mwSize sz; sz=sizeof(%s)*mxGetM(plhs[%d])*mxGetN(plhs[%d]);\n',...
                        matlab2Ctype(outputs{i}.type),i-1,i-1);
                fprintf(fid,'      write(fid,&sz,sizeof(sz)); }\n',inputs{i}.name);
              otherwise
                error('createGateway: output array of dimension %d not implemented\n');
            end
        end
        fprintf(fid,'   /* sizes */\n');
        for i=1:length(sizes)
            fprintf(fid,'      write(fid,&%s,sizeof(%s));\n',sizes{i},sizes{i});
        end

        fprintf(fid,'   close(fid); }\n');

        % close gateway function
        fprintf(fid,'}\n');

        fprintf(fid,'\n#include "%s_raw.c"\n',cmexname);

        % create standalone main()
        fmid=fopen(sprintf('%s_salone.c',cmexname),'w');

        fprintf(fmid,'#include "mex.h"\n#include "math.h"\n');
        fprintf(fmid,'#include <string.h>\n#include <stdint.h>\n#include <fcntl.h>\n#include <unistd.h>\n#include <pthread.h>\n\n');
        %fprintf(fmid,'int mexPrintf(const char *fmt,...) { return 0; };\n\n');
        fprintf(fmid,'#define mexPrintf(...) fprintf (stderr, __VA_ARGS__)\n');

        % declare function that does work
        fprintf(fmid,'extern void %s_raw(\n',cmexname);
        if length(inputs)>0
            fprintf(fmid,'   /* inputs */');
        end
        comma='';
        for i=1:length(inputs)
            fprintf(fmid,'%c\n   %s *%s',comma,matlab2Ctype(inputs{i}.type),inputs{i}.name);
            comma=',';
        end
        if length(outputs)>0
            fprintf(fmid,'\n   /* outputs */');
        end
        for i=1:length(outputs)
            fprintf(fmid,'%c\n   %s *%s',comma,matlab2Ctype(outputs{i}.type),outputs{i}.name);
            comma=',';
        end
        if length(sizes)>0
            fprintf(fmid,'\n   /* sizes */');
        end
        for i=1:length(sizes)
            fprintf(fmid,'%c\n   mwSize %s',comma,sizes{i});
            comma=',';
        end
        fprintf(fmid,');\n\n');

        fprintf(fmid,'int main() { \n');
        % declare variables
        fprintf(fmid,'   /* inputs */\n');
        for i=1:length(inputs)
            fprintf(fmid,'   %s *%s;\n',matlab2Ctype(inputs{i}.type),inputs{i}.name);
        end
        if length(outputs)>0
            fprintf(fmid,'   /* outputs */\n');
        end
        for i=1:length(outputs)
            fprintf(fmid,'   %s *%s;\n',matlab2Ctype(outputs{i}.type),outputs{i}.name);
        end
        fprintf(fmid,'   /* sizes */\n');
        for i=1:length(sizes)
            fprintf(fmid,'   mwSize %s;\n',sizes{i});
        end
        fprintf(fmid,'\n   /* Read inputs from file */\n');
        fprintf(fmid,'{ int fid=open("%s.bin",O_RDONLY,0);\n',cmexname);
        %fprintf(fmid,'   fprintf(stderr,"fid=%%d\\n",fid);\n');
        fprintf(fmid,'   /* inputs */\n');
        for i=1:length(inputs)
            fprintf(fmid,' { mwSize sz;\n');
            fprintf(fmid,'   read(fid,&sz,sizeof(sz));\n');
            %fprintf(fmid,'   fprintf(stderr,"allocating %%lu bytes to %s\\n",sz);\n',inputs{i}.name);
            fprintf(fmid,'   if ((%s=malloc(sz))==NULL) exit(1);\n',inputs{i}.name);
            %fprintf(fmid,'   fprintf(stderr,"reading %%lu bytes to %s\\n",sz);\n',inputs{i}.name);
            fprintf(fmid,'   read(fid,%s,sz); }\n',inputs{i}.name);
        end
        if length(outputs)>0
            fprintf(fmid,'   /* outputs'' sizes */\n');
        end
        for i=1:length(outputs)
            fprintf(fmid,' { mwSize sz;\n');
            fprintf(fmid,'   read(fid,&sz,sizeof(sz));\n');
            %fprintf(fmid,'   fprintf(stderr,"allocating %%lu bytes to %s\\n",sz);\n',outputs{i}.name);
            fprintf(fmid,'   %s=malloc(sz); }\n',outputs{i}.name);
        end
        fprintf(fmid,'   /* sizes */\n');
        for i=1:length(sizes)
            fprintf(fmid,'   read(fid,&%s,sizeof(%s));\n',sizes{i},sizes{i});
            %fprintf(fmid,'   fprintf(stderr,"%s=%%lu\\n",%s);\n',sizes{i},sizes{i});
        end
        fprintf(fmid,'}\n');

        % call function that does work
        fprintf(fmid,'\n   /* Call function */\n');
        fprintf(fmid,'   %s_raw(',cmexname);
        comma='';
        for i=1:length(inputs)
            fprintf(fmid,'%c%s',comma,inputs{i}.name);
            comma=', ';
        end
        for i=1:length(outputs)
            fprintf(fmid,'%c%s',comma,outputs{i}.name);
            comma=', ';
        end
        for i=1:length(sizes)
            fprintf(fmid,'%c%s',comma,sizes{i});
            comma=', ';
        end
        fprintf(fmid,');\n');

        % close main function
        fprintf(fmid,'}\n');

        fprintf(fmid,'\n#include "%s_raw.c"\n',cmexname);

        fclose(fmid);
    end

    fclose(fid);
end

function [s1,s2,s3,wholeline,linenum]=getLine(fcmext,linenum)

    while 1
        linenum=linenum+1;
        wholeline=fgets(fcmext);
        if ~ischar(wholeline)
            s1='';
            s2='';
            s3='';
            return;
        end
        line=textscan(wholeline,'%s %s %s',1,'CommentStyle','%');
        if isempty(line{1})
            continue;
        else
            break;
        end
    end
    s1=line{1}{1};
    s2=line{2}{1};
    if isempty(line{3}{1})
        s3={};
    else
        s3=regexprep(line{3}{1},'\[(.*)\]','$1');
        s3=textscan(s3,'%s','Delimiter',',');
        s3=s3{1};
    end

    if 0
       fprintf('|"%s" "%s" [',s1,s2);
       fprintf('"%s",',s3{:});
       fprintf(']\n');
    end
end

function str=matlab2Ctype(str)

      switch (str)
        case {'uint8','uint16','uint32','uint64','int8','int16','int32','int64'}
          str=sprintf('%s_t',str);
        case {'double','single'}
        otherwise
          error('createGateway: unkown type %s\n',str);
      end
end

function str=matlab2CtypeTest(str)

    switch (str)
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
        error('createGateway: unkown type %s\n',str);
    end
end

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
        error('createGateway: unkown type %s\n',str);
    end
end
