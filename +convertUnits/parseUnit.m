classdef parseUnit < handle
    % UnitDims manages the composition of base units of a derived unit
    
    properties
        dims;
        val = 1;
        validUnits;
        unitDims = UnitDims();
    end
    
    methods
        
        function obj = parseUnit( str )
            obj.validUnits = load('units_LUT.mat');
            obj.validUnits = obj.validUnits.units_LUT;
            obj.unitDims = UnitDims();
            if nargin >= 1
                obj.parse(str);
            end
        end
       
        function parse( obj, str )
            
            % sanitize
            str = strtrim(lower(str));
            
            state = 'unit';
            cache = Stack_char();
            cache.push('*');

            for i = 1:length(str)
                c = str(i);
                switch state
                    case 'unit'
                        if obj.isNum(c)
                            % deal with 'numeric units'
                            if cache.size() == 1
                                cache.push(c);
                                state = 'num';
                            else
                                % deal with unraised powers
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
                                    cache.push(c);
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
                                    % assume we went into a unit with the
                                    % numbers in it's label
                                    % remove ^
                                    cache_temp = strrep(cache.content(), ...
                                                                '^','');
                                    cache.reset([cache_temp c]);
                                    state = 'unit';                                    
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
                               parDims = parseUnit(parContent(2:end-1));
                               
                               % use only the val property if parContent is
                               % intended for use as a power
                               if cache.peek() == '^'
                                   cache.push(num2str(parDims.val));
                                   state = 'num';
                               else
                                   % otherwise, process each entry
                                   dim_ = parDims.unitDims;
                                   val_ = parDims.val;
                                   switch cache.top()
                                       case '*'
                                           UnitDims.plus(obj.unitDims, dim_);
                                           obj.val = obj.val .* val_;
                                       case '/'
                                           UnitDims.minus(obj.unitDims, dim_);
                                           obj.val = obj.val ./ val_;
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
            str = char(obj.unitDims);
        end
        
        % string
        function str = string(obj)
            str = string(obj.unitDims);
        end
        
        % equal
        function bool = eq(pU1, pU2)
            bool = pU1.unitDims == pU2.unitDims;
        end
        
        % not equal
        function bool = ne(pU1, pU2)
            bool = ~(pU1.unitDims == pU2.unitDims);
        end
        
        % rdivide
        function quot = rdivide(pU1, pU2)
            quot = pU1.val ./ pU2.val;
        end
        
        % mrdivide
        function quot = mrdivide(pU1, pU2)
            quot = pU1 ./ pU2;
        end
        
    end
    
    methods (Access = private)
        
        % is valid Unit
        function idx = isValidUnit(obj, unitLabel)
            idx = find(strcmp(...
                                obj.validUnits.Properties.RowNames,...
                                unitLabel));
            if isempty(idx)
                idx = -1;
            end
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
            elseif ~isnan(str2double(str(2:end)))
                obj.val = eval([num2str(obj.val), str]);
            else
                 % find operator
                powerSign = str(1);
                switch powerSign
                    case '*'
                        powerSign = 1;
                    case '/'
                        powerSign = -1;
                    otherwise
                        obj.throwError(str, 1);
                end

                % power and unit label
                powPos = strfind(str,'^');
                if ~isempty(powPos)
                    power = str2double(str(powPos+1:end));
                    unitLabel = str(2:(powPos-1));
                else
                    power = 1;
                    unitLabel = str(2:end);
                end
                
                % apply powerSign modifier
                power = powerSign * power;

                % save entry
                % try to find unit label in the LUT
                if obj.isValidUnit(unitLabel)
                    % get the dims of the unit
                    try
                        unit = UnitDims(obj.validUnits(unitLabel, :).UnitDimensions);
                    catch ME
                        error('unitLabel: %s, is invalid', unitLabel);
                    end
                    % apply the power
                    unit = unit.*power;
                    % add to current unitdims
                    obj.unitDims = obj.unitDims + unit;
                    
                    % calculate conversion factor
                    unitFactor = obj.validUnits(unitLabel, :).Value;
                    obj.val = obj.val .* unitFactor.^power;
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
    
    
end
        