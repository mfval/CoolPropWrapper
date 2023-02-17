classdef UnitDims < handle
    % UnitDims manages the composition of base units of a derived unit
    
    properties
        dims = struct('L', 0, ...   % Length
                      'M', 0, ...   % Mass
                      'N', 0, ...   % Moles
                      'T', 0, ...   % Time
                      'D', 0, ...   % Temperature
                      'I', 0, ...   % Illuminance
                      'A', 0, ...   % Angles
                      'C', 0, ...   % Charge
                      'O', 0);      % Cost
        val = 1;
        validDims;
    end
    
    methods
        
        function obj = UnitDims( str )
            obj.validDims = cell2mat(fieldnames(obj.dims))';
            if nargin >= 1
                if isstruct(str)
                    % TODO, make sure valid dims and dims match
                    obj.dims = str;
                elseif isstring(str)
                    obj.parse(convertStringsToChars(str));
                elseif ischar(str)
                    obj.parse(str);
                end
            end
        end
       
        function parse( obj, str )
            
            % sanitize
            str = strtrim(str);
            
            state = 'unit';
            cache = Stack_char();
            cache.push('*');

            for i = 1:length(str)
                c = str(i);
                switch state
                    case 'unit'
                        if obj.isValidDim(c)
                            cache.push(c);
                        elseif obj.isNum(c)
                            % TODO deal with unraised powers
                            if cache.size() == 1
                                cache.push(c)
                                state = 'num';
                            else
                                cache.push('^');
                                cache.push(c);
                                state = 'num';
                            end
                        elseif obj.isOpeningPar(c)
                        	state = 'par';
                            parCache = Stack_char();    % holds everything incl. pars
                            parCache.push(c);
                            parTree = Stack_char();    % holds only pars
                            parTree.push(c);
                        else
                            switch c
                                case '^'
                                    state = 'num';
                                    cache.push(c);
                                case {'*', '/', '-'}
                                    obj.processEntry(cache.content());
                                    switch c
                                        case {'*', '/'}
                                            cache.reset();
                                            cache.push(c);
                                        case '-'
                                            lastOp = cache.top();
                                            cache.reset();
                                            cache.push(lastOp);
                                    end
                                otherwise
                                    obj.throwError(str, i);
                            end
                            
                        end
                    case 'num'
                        if obj.isNum(c)
                            cache.push(c);
                        elseif cache.peek() == '^' && c == '-'
                            cache.push(c);
                        elseif obj.isOpeningPar(c)
                        	state = 'par';
                            parCache = Stack_char();    % holds everything incl. pars
                            parCache.push(c);
                            parTree = Stack_char();    % holds only pars
                            parTree.push(c);
                        else 
                            switch c
                                case {'*', '/', '-'}
                                    obj.processEntry(cache.content());
                                    state = 'unit';
                                    switch c
                                        case {'*', '/'}
                                            cache.reset();
                                            cache.push(c);
                                        case '-'
                                            lastOp = cache.top();
                                            cache.reset();
                                            cache.push(lastOp);
                                    end
                                otherwise
                                    obj.throwError(str, i);
                            end
                            
                        end
                        
                    case 'par'
                        if obj.isClosingPar(c)
                            if c == obj.closingParOf(parTree.peek())
                                parTree.pop();
                                parCache.push(c);
                            else
                                obj.throwError(str, i, 'Par mismatch');
                            end
                            
                            if parTree.empty()
                               % TODO: Process stuff in the par
                               % process content in parcache without 1,end
                               % pars
                               parContent = parCache.content();
                               parDims = UnitDims(parContent(2:end-1));
                               
                               % use only the val property if parContent is
                               % intended for use as a power
                               if cache.peek() == '^'
                                   cache.push(num2str(parDims.val));
                                   state = 'num';
                               else
                                   % otherwise, process each entry
                                   validDims_ = obj.validDims;
                                   for i_ = 1:length(validDims_)
                                      op_ = cache.top();
                                      dim_ = validDims_(i_);
                                      pow_ = num2str(parDims.dims.(dim_));
                                      
                                      obj.processEntry([op_ dim_ '^' pow_]);
                                   end
                                   state = 'unit';
                               end
                                   
                            end
                        elseif obj.isOpeningPar(c)
                            parCache.push(c);
                            parTree.push(c);
                        else
                            parCache.push(c);
                        end
                    otherwise
                end
                
            end
            
            % wrap up any remainder cache data
            if ~cache.empty()
                obj.processEntry(cache.content());
            end
            
            % something wrong is par tree is not empty
            if (exist('parTree','var') && ~parTree.empty())
                obj.throwError(str,i);
            end
            
        end
        
        % char
        function str = char(obj)
            strNum = '';
            strDen = '';
            units = fieldnames(obj.dims);
            for i = 1:length(units)
                label = units{i};
                power = obj.dims.(units{i});
                if power == 0
                    continue
                elseif power > 0
                    if power == 1
                        strNum = [strNum sprintf('%s-',label)];
                    else
                        strNum = [strNum sprintf('%s^%d-',label,power)];
                    end
                else
                    if power == -1
                        strDen = [strDen sprintf('%s-',label)];
                    else
                        strDen = [strDen sprintf('%s^%d-',label,-power)];
                    end
                end
            end
            strNum = strNum(1:end-1);
            strDen = strDen(1:end-1);
            
            if isempty(strNum) && isempty(strDen)
                str = '(-)';
            elseif isempty(strNum)
                str = ['1/(' strDen ')'];
            elseif isempty(strDen)
                str = strNum;
            else
                str = ['(' strNum ')/(' strDen ')'];
            end
        end
        
        function str = string(obj)
            str = string(char(obj));
        end
        
        % plus
        function ud1 = plus(ud1, ud2)
            units = fieldnames(ud1.dims);
            for i = 1:length(units)
                ud1.dims.(units{i}) = ud1.dims.(units{i}) + ud2.dims.(units{i});
            end
        end
        
        % minus
        function ud1 = minus(ud1, ud2)
           
            units = fieldnames(ud1.dims);
            for i = 1:length(units)
                ud1.dims.(units{i}) = ud1.dims.(units{i}) - ud2.dims.(units{i});
            end
            
        end
        
        % times
        function ud1 = times(ud1, n)
           
            units = fieldnames(ud1.dims);
            for i = 1:length(units)
                ud1.dims.(units{i}) = ud1.dims.(units{i}) .* n;
            end
            
        end
        
        % mtimes
        function ud1 = mtimes(ud1, n)
            ud1 = ud1.*n;
        end
        
        % equal
        function bool = eq(ud1, ud2)
            bool = 1;
            units = fieldnames(ud1.dims);
            for i = 1:length(units)
                bool = bool .* (ud1.dims.(units{i}) == ud2.dims.(units{i}));
            end
            bool = logical(bool);
        end
       
        % not equal
        function bool = ne(ud1, ud2)
            bool = ~(ud1==ud2);
        end        
        
    end
    
    methods (Access = private)
        
        % is valid dim
        function bool = isValidDim(obj, c)
            bool =contains(cell2mat(fieldnames(obj.dims)).',c);
        end
        
        % Determines if c is numeric
        function bool = isNum(obj, c)
            c_ascii = double(c);   
            bool = 0;
            if c_ascii >= 48 && c_ascii <=57
                bool = 1;
            end    
        end
        
        % Determines if c is a paretheses character
        function bool = isPar(obj,c)
            bool = false;
            if isOpeningPar(c) || isClosingPar(c)
                bool = true;
            end
        end

        % Determines if c is an opening parentheses
        function bool = isOpeningPar(obj,c)
            bool = false;
            if c == '(' || c == '[' || c == '{'
                bool = true;
            end
        end

        % Determines if c is a closing parentheses
        function bool = isClosingPar(obj,c)
            bool = false;
            if c == ')' || c == ']' || c == '}'
                bool = true;
            end
        end
        
        % Get the closing paretheses of c
        function par = closingParOf(obj, c)
            switch c
                case '('
                    par = ')';
                case ')'
                    par = ')';
                otherwise
                    par = -1;   % maybe dont need this?
            end
        end
        
        % Process items in the entry string
        function processEntry(obj, str)
            % For numeric values
            if length(str) == 1
                return;
            elseif length(str) == 2 && ~isempty(str2num(str(2)))
                obj.val = eval([num2str(obj.val), str]);
            else
                 % find operator
                powerSign = str(1);
                switch powerSign
                    case '*'
                        powerSign = 1;
                    case '/'
                        powerSign = -1;
                end

                % dim
                dim = str(2);
            
                % power
                if length(str) <= 3
                    power = 1;
                else
                    power = str2double(str(4:end));
                end

                % apply powerSign modifier
                power = powerSign * power;

                % save entry
                % if is dim
                if obj.isValidDim(dim)
                    obj.dims.(dim) = obj.dims.(dim) + power;
                else
                    obj.val = eval([num2str(obj.val), str]);
                end
            end
            
        end
        
        
        % Builds hint message for debugging errors
        function throwError(obj, str, i, msg)
            if nargin < 4
                msg = '';
            end
            n = length(str);
            error('An error occurred near ...%s...%s',...
                        str(max(1,i-5):min(n,i+5)),...
                        msg);
        end
        
    end
    
    methods (Static)
        
    end
    
    
end
        