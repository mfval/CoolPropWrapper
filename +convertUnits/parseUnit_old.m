function parseUnit(str, units_LUT)

% sanitize input str
str = strtrim(lower(str));

if nargin < 2
    units_LUT = load('./units_LUT.mat');
    units_LUT = units_LUT.units_LUT;
end


% PARSE
% all units are assumed to be a division of two products of units
% this function runs recursively until not parentheses exist in a block
% ___ states
%   - unit <string>
%   - numeric 0,1,2,3...
%   - operator *,-,/,^
%   - parentheses (,),[,]

parsedUnit = Unit();

currState = 'init';
cache = Stack_char();
parCache = Stack_char();

ops = Stack_char();
ops.push('m');

conversionFactor = 1;

for i=1:length(str)
    
    c = str(i);
    
	switch currState
        case 'init'
            if isOp(c)
                % shouldn't start or end with an op
                if i==1 || i == length(str)
                    throwError(str, i);
                end
                    
            elseif isPar(c)
                cache.reset();
                currState = 'parentheses';
                cache.push(c);
                parCache.push(c);
            else
                currState = 'unit';
                cache.push(c);
            end
            
        case 'parentheses'
            if isOp(c)
                % a operator can't appear immediately after an opening par
                if isOpeningPar(cache.peek())
                    throwError(str, i);
                end
                % otherwise, add operator to cache.
                % leaving for the recursively called instance to process
                cache.push(c);
            elseif isPar(c)
                % What kind of par is c
                if isOpeningPar(c)
                    %  an opening par can be simply added
                    cache.push(c);
                    parCache.push(c);
                elseif isClosingPar(c)
                    % a closing par needs to match last par in cache
                    % otherwise, throw error!
                    if closingParOf(parCache.peek()) == c
                        % pop last par cache char
                        parCache.pop();
                        % add closing par to cache
                        cache.push(c);
                        % if this is 'the' closing par,
                        % process the cache
                        if isempty(parCache)
                            [parsedNum, parsedDen] = ...
                                parseUnit(cache.content(2:end-1), units_LUT);
                        end
                    else
                        throwError(str, i);                        
                    end
                end
            else
                % assuming proper character here, might want to sanitize
                cache.push(c);
            end
        case 'unit'
            if isPar(c)
                % a par should preceed with an operator or nothing at all
                throwError(str, i);
            elseif isOp(c)
                %TODO: deal with unit in cache
                % find unraised power values (numeric only) ex m2 = m^2
                powerStr = '';
                while ~cache.empty()
                    if isNum(cache.peek())
                        powerStr = [cache.pop(), powerStr];
                    else
                        break;
                    end
                end
                if isempty(powerStr)
                    power = 1;
                else
                    power = str2double(powerStr);
                end
                
                % deal with rest of the cache/unit
                unitStr = cache.content();
                try
                    unit = units_LUT(unitStr, :);
                catch ME
                    % throw error if unit isn't found
                    switch ME.identifier
                        case 'MATLAB:table:UnrecognizedRowName'
                            throwError(str, i, ...
                                sprintf('%s is invalid', unitStr));
                        otherwise
                            throwError(str, i);
                    end
                end
                    unit 
                        
            else
                % otherwise, add to cache
                cache.push(c);
            end
                
%         otherwise
	end
            
end




% Determines if c is an operator character
function bool = isOp(c)
    switch c
        case {'*','-','/'}
            bool = 1;
        otherwise
            bool = 0;
    end
end

% Determines if c is numeric
function bool = isNum(c)
    c_ascii = double(c);   
    bool = 0;
    if c_ascii >= 48 && c_ascii <=57
        bool = 1;
    end    
end

% Determines if c is a paretheses character
function bool = isPar(c)
    bool = false;
    if isOpeningPar(c) || isClosingPar(c)
        bool = true;
    end
end

% Determines if c is an opening parentheses
function bool = isOpeningPar(c)
    bool = false;
    if c == '(' || c == '[' || c == '{'
        bool = true;
    end
end

% Determines if c is a closing parentheses
function bool = isClosingPar(c)
    bool = false;
    if c == ')' || c == ']' || c == '}'
        bool = true;
    end
end

% Builds hint message for debugging errors
function throwError(str, i, msg)
    if nargin < 3
        msg = '';
    end
    n = length(str);
    error('An error occurred near ...%s...%s',...
                str(max(1,i-5),min(n,i+5)),...
                msg);
end

% Get the closing paretheses of c
function par = closingParOf(c)
    switch c
        case '('
            par = ')';
        case ')'
            par = ')';
        otherwise
            par = -1;   % maybe dont need this?
    end
end
    
end