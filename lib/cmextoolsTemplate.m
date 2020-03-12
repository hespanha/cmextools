function template=cmextoolsTemplate()

    template=struct('MEXfunction',{},...% string
                    'Sfunction',{},...  % string
                    'Cfunction',{},...  % string
                    'method',{},...     % string
                    'help',{},...       % string
                    'inputs',struct(...  
                        'type',{},...   % string
                        'name',{},...   % cell-array of strings (one per dimension)
                        'sizes',{}),... % cell-array of strings (one per dimension)
                    'outputs',struct(...% string
                        'type',{},...   % string
                        'name',{},...   % cell-array of strings (one per dimension)
                        'sizes',{}),... % cell-array of strings (one per dimension)
                    'preprocess',{},... % strings (starting with parameters in parenthesis)
                    'includes',{});     % cell-array of strings (one per file)
end
