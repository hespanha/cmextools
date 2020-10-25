function classHelp=helpFromTemplate(className,template)
% Automatically generate help from createGateway templates

    classHelp={'Create object';
               sprintf('  obj=%s();',className)};
    classHelp{end+1}='Methods';
    for t=1:length(template)
        classHelp{end+1}='  ';
        if ~isempty(template(t).outputs)
            for i=1:length(template(t).outputs)
                if i==1
                    classHelp{end}(end+1)='[';
                else
                    classHelp{end}(end+1)=',';
                end
                msize=template(t).outputs(i).sizes;
                if isnumeric(msize)
                    msize=arrayfun(@(x)sprintf('%g',x),msize,'uniform',false);
                end
                while length(msize)<2
                    msize{end+1}='1';
                end
                classHelp{end}=[classHelp{end},' ',template(t).outputs(i).name,...
                                ' [',sprintf('%s,',msize{:})];
                classHelp{end}(end)=']';
            end
            classHelp{end}=[classHelp{end},' ] = '];
        end
        classHelp{end}=[classHelp{end},template(t).method,'(obj'];
        if ~isempty(template(t).inputs)
            for i=1:length(template(t).inputs)
                msize=template(t).inputs(i).sizes;
                if isnumeric(msize)
                    msize=arrayfun(@(x)sprintf('%g',x),msize,'uniform',false);
                end
                while length(msize)<2
                    msize{end+1}='1';
                end
                classHelp{end}=[classHelp{end},', ',template(t).inputs(i).name,...
                                ' [',sprintf('%s,',msize{:})];
                classHelp{end}(end)=']';
            end
        end
        classHelp{end}(end+1)=')';
        if ~isempty(template(t).help)
            if length(classHelp{end})<70
                classHelp{end}=[classHelp{end},' - ',template(t).help];
            else
                classHelp{end+1}=['       - ',template(t).help];
            end
        end
        if length(template(t).outputs)>0
            % outputs as a structure
            classHelp{end+1}=['  y (struct) = ',template(t).method,'(obj'];
            if ~isempty(template(t).inputs)
                for i=1:length(template(t).inputs)
                    msize=template(t).inputs(i).sizes;
                    if isnumeric(msize)
                        msize=arrayfun(@(x)sprintf('%g',x),msize,'uniform',false);
                    end
                    while length(msize)<2
                        msize{end+1}='1';
                    end
                    classHelp{end}=[classHelp{end},', ',template(t).inputs(i).name,...
                                    ' [',sprintf('%s,',msize{:})];
                    classHelp{end}(end)=']';
                end
            end
            classHelp{end}(end+1)=')';
            if ~isempty(template(t).help)
                if length(classHelp{end})<70
                    classHelp{end}=[classHelp{end},' - ',template(t).help];
                else
                    classHelp{end+1}=['       - ',template(t).help];
                end
            end
        end
    end

end