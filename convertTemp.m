function value = convertTemp(from,to,value)

    switch from 
        case {'K','k'}
            switch to
                case {'C','c'}
                    value = value - 273.15;
                case {'F','f'}
                    value = convertTemp('K','R',value);
                    value = convertTemp('R','F',value);
                case {'R','r'}
                    value = value .* 1.8;
                case {'K','k'}
                otherwise
                    warning('Unknown target temperature.');
            end
        case {'R','r'}
            switch to
                case {'F','f'}
                    value = value - 459.67;
                case {'C','c'}
                    value = convertTemp('R','K',value);
                    value = convertTemp('K','C',value);
                case {'K','k'}
                    value = value .* (5/9);
                otherwise
                    warning('Unknown target temperature.');
            end
        case {'C','c'}
            value = value + 273.15;
            value = convertTemp('K',to,value);
        case {'F','f'}
            value = value + 459.67;
            value = convertTemp('R',to,value);
        otherwise
            warning('Unknown initial temperature unit used.');
    end
        
        