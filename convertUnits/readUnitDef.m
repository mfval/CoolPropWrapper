function [units, units_LUT] = readUnitDef(path)

% open unit definition
fid = fopen(path,'r');

% structure for units
units = struct();
units_LUT = {};

% start reading line by line
i = 0;
j = 0;
while true
    
    % read next line
    currLine = fgetl(fid);
    i = i + 1;
    
    % break if EOF, continue if empty line
    if currLine == -1
        break;
    elseif strcmp(currLine, '')
        continue;
    end
    
    % split line to 2
    splitLine = strsplit(currLine, '\t');
    
    % stop and error if not exactly 2 items were found.
    numItems = length(splitLine);
    if numItems ~= 2
        error(-1,'%u items were found on line %u', numItems, i);
    end
    
    % split line to label and value
    label = strtrim(lower(splitLine{1}));
    val = strtrim(lower(splitLine{2}));
    
    % add new type of units if label starts with '$'
    if strcmp(label(1), '$')
        currUnitLabel = label(2:end);
        currUnitLabel(1) = upper(currUnitLabel(1));
        currUnitDims = UnitDims(upper(val(2:end-1)));
        currUnitDims = currUnitDims.dims;
        units.(currUnitLabel) = struct('type', currUnitDims, ...
                                       'units', struct('label',{},'val',{}));
	% add unit entry for current unit label
    elseif strcmp(label(1), '%')
        continue;
    else
        % Found new unit entry, increment counter
        j = j + 1;

        % Treat '#' as an escape character
        if strcmp(label(1),'#')
            label = label(2:end);
        end

        % for the units structure
        val = str2double(val);
        units.(currUnitLabel).units(end+1).label = label;
        units.(currUnitLabel).units(end).val = val;
        
        % for the look up table
        units_LUT(j,:) = {label,val,currUnitLabel,currUnitDims};
    end
    
    
    
    
end

% convert LUT to table
units_LUT = cell2table(units_LUT(:,2:end),...
                'VariableNames',{'Value','UnitType','UnitDimensions'},...
                'RowNames',units_LUT(:,1));

% Close file
fclose(fid);

save('units_LUT.mat', 'units_LUT')
fprintf('Saved units_LUT file\n')

end
