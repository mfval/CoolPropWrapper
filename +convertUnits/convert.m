function factor = convert(a,b)
    a = parseUnit(a);
    b = parseUnit(b);
	
    % check for temperature base unit
    temp_base_unit = parseUnit('K');
    
    if a~=b
        error('%s is incompatible with %s',a,b);
    elseif a==b && a == temp_base_unit
        warning('Seems like you are trying to convert base temperatures. Use `convertTemp` instead.');
    end
    
    factor = a/b;
end