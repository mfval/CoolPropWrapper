classdef CoolPropWrapper < handle
    %CoolPropWrapper Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fluid = 'R245fa'
        CoolPropHandle      % ie. py.CoolProp
        CoolProp            % ie. py.CoolProp.AbstactState(...)
        AbstractStateSrc = 'BICUBIC&HEOS';
        params
        inputPairType
        outputMode = 'mat'
    end
    
    methods
        function obj = CoolPropWrapper(fluidName)
            %CoolPropWrapper Construct an instance of this class
            %   fluidName defaults to R245fa if not specified
            if nargin == 1
                obj.fluid = fluidName;
            end
            try
                obj.CoolPropHandle = py.importlib.import_module('CoolProp');
                obj.setFluid(obj.fluid);
                obj.getCoolPropParameters();
            catch ME
                
                warning(ME.message);
                [~,e]=pyversion;
               if ~isempty(e)
                    res = questdlg('A python module has been found, but CoolProp might have not been installed. Should I install it?',...
                                    'Install CoolProp?','Yes','No','Yes');
                    if strcmp('Yes',res)
                        system([e,' -m pip install --user -U CoolProp']);
                    end
                    warning('Please install CoolProp and/or restart MATLAB.');
               else
                    defaultPath = fullfile(getenv('LOCALAPPDATA'),'Programs','Python','Python310');
                    try
                        pyversion(fullfile(defaultPath, 'python.exe'));
                    catch ME
                        disp('Python version info:')
                        pyversion
                    end
                    locationCmd = sprintf("system(['explorer ','%s']);",defaultPath);
                    
                    warning('Not sure what happened. Verify Python v3.7+ and the Coolprop Library are installed.');
                    warning('Python is usually installed <a href="matlab:%s">HERE</a>.',locationCmd);
                    warning('For more info: <a href="http://www.coolprop.org/coolprop/wrappers/MATLAB/index.html">http://www.coolprop.org/coolprop/wrappers/MATLAB/index.html</a>.');
                    error('Stopping now.');
                end
                    
            end
            
        end
        function setAbstractStateSrc(obj, src)
            src = upper(src);
            switch src
                case {'HEOS','TTSE&HEOS','BICUBIC&HEOS'}
                    obj.AbstractStateSrc = src;
                    obj.setFluid(obj.fluid);
                case {'DEFAULT','RESET'}
                    obj.AbstractStateSrc = 'BICUBIC&HEOS';
                    obj.setFluid(obj.fluid);
                otherwise
                    error('%s is not a valid Abstract State source\n',...
                                src);
            end
        end
        function setFluid(obj,fluidName)
            %setFluid Change fluid
            try
                obj.fluid = fluidName;
                obj.CoolProp = ...
                    obj.CoolPropHandle.AbstractState(obj.AbstractStateSrc, obj.fluid);
            catch ME
                warning(ME.message);
            end
        end
        function setOutputMode(obj, outputMode)
            switch lower(outputMode)
                case 'mat'
                    obj.outputMode = 'mat';
                case 'vec'
                    obj.outputMode = 'vec';
                otherwise
                    error('Invalid output mode. [mat|vec]');
            end
        end
        function setPhase(obj,phase)
            obj.setSpecifyPhase(phase)
        end
        function setSpecifyPhase(obj,phase)
            %setSpecfiyPhase impose phase
            if nargin < 2 
                phase = '';
            end
            phase = obj.scrubInput(phase);
            switch phase
               case 'liquid'
                   phase = obj.CoolPropHandle.iphase_liquid;
                case 'gas'
                    phase = obj.CoolPropHandle.iphase_gas;
                case 'twophase'
                    phase = obj.CoolPropHandle.iphase_twophase;
                otherwise
                    phase = obj.CoolPropHandle.iphase_not_imposed;
            end
            obj.CoolProp.specify_phase(phase);
        end
        function phase = getSpecifyPhase(obj)
            phase = obj.CoolProp.phase();
            phase = obj.phaseEnum2str(phase);
        end
        function T = temperature(obj,Atype,A,Btype,B)
            %temperature calculates the temperature 
            %   TODO
            T = obj.property(Atype,A,Btype,B,{'t'});
        end
        function P = pressure(obj,Atype,A,Btype,B)
            %pressure calculates the pressure 
            %   TODO
            P = obj.property(Atype,A,Btype,B,{'p'});
        end
        function h = enthalpy(obj,Atype,A,Btype,B)
            %enthalpy calculates the enthalpy 
            %   TODO
            h = obj.property(Atype,A,Btype,B,{'h'});
        end
        function s = entropy(obj,Atype,A,Btype,B)
            %entropy calculates the entropy
            %   TODO
            s = obj.property(Atype,A,Btype,B,{'s'});
        end
        function rho = density(obj,Atype,A,Btype,B)
            %density calculates the density
            %   TODO
            rho = obj.property(Atype,A,Btype,B,{'rho'});
        end
        function k = conductivity(obj,Atype,A,Btype,B)
            %conductivity calculates the conductivity
            %   TODO
            k = obj.property(Atype,A,Btype,B,{'k'}); 
        end
        function mu = viscosity(obj,Atype,A,Btype,B)
            %viscosity calculates the viscosity
            %   TODO
            mu = obj.property(Atype,A,Btype,B,{'mu'}); 
        end
        function cp = cp(obj,Atype,A,Btype,B)
            %cp returns the constant pressure specific heat 
            %  TODO
            cp = obj.property(Atype,A,Btype,B,{'cp'}); 
        end
        function cv = cv(obj,Atype,A,Btype,B)
            %cv returns the mass constant volume specific heat 
            %   TODO
            cv = obj.property(Atype,A,Btype,B,{'cv'}); 
        end
        function pr = prandtl(obj,Atype,A,Btype,B)
            %prandtl returns the Prandtl number
            %   TODO
            pr = obj.property(Atype,A,Btype,B,{'pr'}); 
        end
        function gamma = surfaceTension(obj,Atype,A,Btype,B)
            %surfaceTension returns the surfaceTension
            %   TODO
            gamma = obj.property(Atype,A,Btype,B,{'gamma'}); 
        end
        function phase = phase(obj,Atype,A,Btype,B)
            %phase returns the phase
            %   TODO: convert enum to string
            phase = obj.property(Atype,A,Btype,B,{'ph'});
        end
        function quality = quality(obj,Atype,A,Btype,B)
            %qualityPT calculates the quality given P and T
            %   TODO, doesn't necessarily work?
            quality = obj.property(Atype,A,Btype,B,{'Q'});
        end
        function Tsat = TsatP(obj,P)
            
            Tsat = obj.property('p',P,'q',zeros(length(P),1),{'t'});
        end
        function Psat = PsatT(obj,T)
            Psat = obj.property('t',T,'q',zeros(length(T),1),{'p'});
        end
        
    end
    
    methods(Access=protected)
        function propVals = retrieveProps(obj, props)
            if ischar(props)
                props = {props};
            end
            propVals = zeros(numel(props),1);
            for k = 1:length(props)
                propName = lower(props{k});
                switch propName
                    case 'p', propVal = obj.CoolProp.p();
                    case 't', propVal = obj.CoolProp.T();
                    case 'h', propVal = obj.CoolProp.hmass();
                    case 's', propVal = obj.CoolProp.smass();
                    case 'k', propVal = obj.CoolProp.conductivity();
                    case 'mu', propVal = obj.CoolProp.viscosity();
                    case 'rho', propVal = obj.CoolProp.rhomass();
                    case 'pr', propVal = obj.CoolProp.Prandtl();
                    case 'cp', propVal = obj.CoolProp.cpmass();
                    case 'cv', propVal = obj.CoolProp.cvmass();
                    case 'gamma', propVal = obj.CoolProp.surface_tension();
                    case 'rhomolar', propVal = obj.CoolProp.rhomolar();
                    case 'q', propVal = obj.CoolProp.Q();
                    case 'ph', propVal = obj.CoolProp.phase();
                    otherwise, propVal = NaN;
                end
                propVals(k)= propVal;
            end
            
        end
        
        function propVals = property(obj,Alabel,A,Blabel,B, props)
            %propertyPT retrieves values for requested properties for all As
            %and Bs
            % A: parameter Alabel vector
            % B: parameter Blabel vector
            % props: cell array of properties to retrieve
            %
            
            % Determind input pair type
            [A, B, swapped] = obj.generateUpdatePair(Alabel, A, Blabel, B);
            
            n = numel(A);       % number of A points
            m = numel(B);       % number of B points
                        
            if obj.outputMode == 'mat'
                % setup propVals container
                propVals = zeros(n,m,numel(props));
                % For every pressure 
                for i = 1:n
                    % For every temperature
                    for j = 1:m
                        % Update AbstractState with AB
                        obj.CoolProp...
                            .update(obj.inputPairType, A(i), B(j));
                        % Retrieve properties.
                        propVals(i,j,:) = obj.retrieveProps(props);
                    end
                end

                % Matrix dimension consistency
                if swapped
                    propVals = permute(propVals, [2 1 3]);
                end
            else
                % lower dimension
                propVals = zeros(n,numel(props));
                % check if length(A)==length(B)
                if n~=m
                    if isscalar(A)
                        n = m;
                        A = A.*ones(n,1);
                    elseif isscalar(B)
                        m = n;
                        B = B.*ones(m,1);
                    else
                        error('Vector size mismatch');
                        return
                    end
                end
                 % For every pressure 
                for i = 1:n
                    % Update AbstractState with AB
                    obj.CoolProp...
                        .update(obj.inputPairType, A(i), B(i));
                    % Retrieve properties.
                    propVals(i,:) = obj.retrieveProps(props);
                end
            end
           
        end
        
        function getCoolPropParameters(obj)
            obj.params = string(obj.CoolPropHandle.get('parameter_list'));
            obj.params = split(obj.params,',');
        end
        function input = scrubInput(obj,input)
           input = strtrim(lower(input)); 
        end
        function [A, B, swapped] = generateUpdatePair(obj, Alabel, A, Blabel, B)
            
            swapped = false;
            
            % Clean labels
            Alabel = obj.scrubInput(Alabel);
            Blabel = obj.scrubInput(Blabel);
                        
            % Matching and swapping algorithm
            function isMatch = matchPair(Alabel, Blabel, Akey, Bkey)
                isMatch = (strcmp(Alabel, Akey) && strcmp(Blabel, Bkey)) || ...
                          (strcmp(Alabel, Bkey) && strcmp(Blabel, Akey));
                if isMatch && ~strcmp(Alabel, Akey)
                    C = B; B = A; A = C; swapped = true;
                end
            end
            
            % Find the correct input pair option
            if matchPair(Alabel,Blabel,'q','t')     % quality, temperature
                obj.inputPairType = obj.CoolPropHandle.QT_INPUTS;
            elseif matchPair(Alabel,Blabel,'p','q') % pressure, quality
                obj.inputPairType = obj.CoolPropHandle.PQ_INPUTS;
            elseif matchPair(Alabel,Blabel,'p','t') % pressure, temperature
                obj.inputPairType = obj.CoolPropHandle.PT_INPUTS;
            elseif matchPair(Alabel,Blabel,'d','t') % density, temperature
                obj.inputPairType = obj.CoolPropHandle.DmassT_INPUTS;
            elseif matchPair(Alabel,Blabel,'h','t') % enthalpy, temperature
                obj.inputPairType = obj.CoolPropHandle.HmassT_INPUTS;
            elseif matchPair(Alabel,Blabel,'s','t') % entropy, temperature
                obj.inputPairType = obj.CoolPropHandle.SmassT_INPUTS;
            elseif matchPair(Alabel,Blabel,'t','u') % termeprature, internal energy
                obj.inputPairType = obj.CoolPropHandle.TUmass_INPUTS;
            elseif matchPair(Alabel,Blabel,'d','h') % density, enthalpy
                obj.inputPairType = obj.CoolPropHandle.DmassHmass_INPUTS;
            elseif matchPair(Alabel,Blabel,'d','s') % density, entropy 
                obj.inputPairType = obj.CoolPropHandle.DmassSmass_INPUTS;
            elseif matchPair(Alabel,Blabel,'d','u') % density, internal energy
                obj.inputPairType = obj.CoolPropHandle.DmassUmass_INPUTS;
            elseif matchPair(Alabel,Blabel,'d','p') % density, pressure
                obj.inputPairType = obj.CoolPropHandle.DmassP_INPUTS;
            elseif matchPair(Alabel,Blabel,'d','q') % density, quality
                obj.inputPairType = obj.CoolPropHandle.DmassQ_INPUTS;
            elseif matchPair(Alabel,Blabel,'h','p') % enthalpy, pressure 
                obj.inputPairType = obj.CoolPropHandle.HmassP_INPUTS;
            elseif matchPair(Alabel,Blabel,'p','s') % pressure, entropy
                obj.inputPairType = obj.CoolPropHandle.PSmass_INPUTS;
            elseif matchPair(Alabel,Blabel,'p','u') % pressure, internal energy
                obj.inputPairType = obj.CoolPropHandle.PUmass_INPUTS;
            elseif matchPair(Alabel,Blabel,'h','s') % enthalpy, entropy
                obj.inputPairType = obj.CoolPropHandle.HmassSmass_INPUTS;
            elseif matchPair(Alabel,Blabel,'s','u') % entropy, internal energy 
                obj.inputPairType = obj.CoolPropHandle.SmassUmass_INPUTS;
            else % uh oh
                obj.inputPairType = obj.CoolPropHandle.INPUT_PAIR_INVALID;
            end
        end
        function phaseStr = phaseEnum2str(obj, phaseEnum)
            switch phaseEnum
                case 0, phaseStr = 'liquid';
                case 1, phaseStr = 'supercritical';
                case 2, phaseStr = 'supercritical_gas';
                case 3, phaseStr = 'supercritical_liquid';
                case 4, phaseStr = 'critical_point';
                case 5, phaseStr = 'gas';
                case 6, phaseStr = 'two_phase';
                case 7, phaseStr = 'unknown';
                case 8, phaseStr = 'not_imposed';
                otherwise, phaseStr = 'unset';
            end
        end
        function phaseEnum = phaseStr2enum(obj, phaseStr)
            switch phaseStr
                case 'liquid'
                    phaseEnum = obj.CoolPropHandle.iphase_liquid;
                case 'supercritical'
                    phaseEnum = obj.CoolPropHandle.iphase_supercritical;
                case 'supercritical_gas'
                    phaseEnum = obj.CoolPropHandle.iphase_supercritical_gas;
                case 'supercritical_liquid'
                    phaseEnum = obj.CoolPropHandle.iphase_supercritical_liquid;
                case 'gas'
                    phaseEnum = obj.CoolPropHandle.iphase_gas;
                case 'twophase'
                    phaseEnum = obj.CoolPropHandle.iphase_twophase;
                case 'unknown'
                    phaseEnum = obj.CoolPropHandle.iphase_unknown;
                case 'not_imposed'
                    phaseEnum = obj.CoolPropHandle.iphase_not_imposed;
                otherwise
                    phaseEnum = NaN;
            end
        end
    end
    
    properties (Constant)
       EOS = struct('HEOS','HEOS',...
                    'TTSE_HEOS','TTSE&HEOS',...
                    'BICUBIC_HEOS','BICUBIC&HEOS');
    end
end

