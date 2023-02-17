classdef CoolPropWrapperHA < handle
    %CoolPropWrapperHA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        CoolPropHandle      % ie. py.CoolProp
        CoolPropHA            % ie. py.CoolProp.AbstactState(...)
    end
    
     methods
        function obj = CoolPropWrapperHA()
            %CoolPropWrapperHA Construct an instance of this class
            %   Detailed explanation goes here
            obj.CoolPropHandle = py.importlib.import_module('CoolProp');
            obj.CoolPropHA = obj.CoolPropHandle.HumidAirProp;
        end
        
        function propVals = property(obj, Alabel, A, Blabel, B, Clabel, C, prop)
            
            paramLabel = obj.param;
            
            % Some variables are input only
            switch prop
                case {paramLabel.Pressure, paramLabel.Pressure_water}
                    error('%s is an input-only parameter\n',prop);
                    return
            end
            % Some variables are output only
            labels = {Alabel, Blabel, Clabel};
            for i=1:length(labels)
                label = labels{i};
                switch label
                    case {paramLabel.cp, ...
                          paramLabel.cp_ha, ...
                          paramLabel.Conductivity, ...
                          paramLabel.Viscosity, ...
                          paramLabel.CompressibilityFactor}
                        error('%s is an output-only parameter\n',label);
                        return
                end
            end
            
            % Alright, time to give it a try
            propVals = obj.CoolPropHA.HAPropsSI(prop,Alabel,A(1),...
                                                     Blabel,B(1),...
                                                     Clabel,C(1));
        end
                
        
        
        function propVals = Wetbulb(obj, Alabel, A, Blabel, B, Clabel, C)
            paramLabel = obj.param;
            propVals = obj.property(Alabel, A, Blabel, B, Clabel, C, ...
                                        paramLabel.WetBulb);
        end
        function propVals = cp(obj, Alabel, A, Blabel, B, Clabel, C)
            paramLabel = obj.param;
            propVals = obj.property(Alabel, A, Blabel, B, Clabel, C, ...
                                        paramLabel.cp);
        end
        function propVals = cp_ha(obj, Alabel, A, Blabel, B, Clabel, C)
            paramLabel = obj.param;
            propVals = obj.property(Alabel, A, Blabel, B, Clabel, C, ...
                                        paramLabel.cp_ha);
        end
        function propVals = Dewpoint(obj, Alabel, A, Blabel, B, Clabel, C)
            paramLabel = obj.param;
            propVals = obj.property(Alabel, A, Blabel, B, Clabel, C, ...
                                        paramLabel.DewPoint);
        end
        function propVals = Enthalpy(obj, Alabel, A, Blabel, B, Clabel, C)
            paramLabel = obj.param;
            propVals = obj.property(Alabel, A, Blabel, B, Clabel, C, ...
                                        paramLabel.Enthalpy);
        end
        function propVals = Enthalpy_ha(obj, Alabel, A, Blabel, B, Clabel, C)
            paramLabel = obj.param;
            propVals = obj.property(Alabel, A, Blabel, B, Clabel, C, ...
                                        paramLabel.Enthalpy_ha);
        end
        
        
        function propVals = Conductivity(obj, Alabel, A, Blabel, B, Clabel, C)
            paramLabel = obj.param;
            propVals = obj.property(Alabel, A, Blabel, B, Clabel, C, ...
                                        paramLabel.Conductivity);
        end
        function propVals = Viscosity(obj, Alabel, A, Blabel, B, Clabel, C)
            paramLabel = obj.param;
            propVals = obj.property(Alabel, A, Blabel, B, Clabel, C, ...
                                        paramLabel.Viscosity);
        end
        function propVals = WaterMoleFraction(obj, Alabel, A, Blabel, B, Clabel, C)
            paramLabel = obj.param;
            propVals = obj.property(Alabel, A, Blabel, B, Clabel, C, ...
                                        paramLabel.WaterMoleFraction);
        end
        function propVals = RelativeHumidity(obj, Alabel, A, Blabel, B, Clabel, C)
            paramLabel = obj.param;
            propVals = obj.property(Alabel, A, Blabel, B, Clabel, C, ...
                                        paramLabel.RelativeHumidity);
        end
        function propVals = Entropy(obj, Alabel, A, Blabel, B, Clabel, C)
            paramLabel = obj.param;
            propVals = obj.property(Alabel, A, Blabel, B, Clabel, C, ...
                                        paramLabel.Entropy);
        end
        function propVals = Entropy_ha(obj, Alabel, A, Blabel, B, Clabel, C)
            paramLabel = obj.param;
            propVals = obj.property(Alabel, A, Blabel, B, Clabel, C, ...
                                        paramLabel.Entropy_ha);
        end
        
        function propVals = DryBulb(obj, Alabel, A, Blabel, B, Clabel, C)
            paramLabel = obj.param;
            propVals = obj.property(Alabel, A, Blabel, B, Clabel, C, ...
                                        paramLabel.DryBulb);
        end
        function propVals = Volume(obj, Alabel, A, Blabel, B, Clabel, C)
            paramLabel = obj.param;
            propVals = obj.property(Alabel, A, Blabel, B, Clabel, C, ...
                                        paramLabel.Volume);
        end
        function propVals = Volume_ha(obj, Alabel, A, Blabel, B, Clabel, C)
            paramLabel = obj.param;
            propVals = obj.property(Alabel, A, Blabel, B, Clabel, C, ...
                                        paramLabel.Volume_ha);
        end
        function propVals = HumidityRatio(obj, Alabel, A, Blabel, B, Clabel, C)
            paramLabel = obj.param;
            propVals = obj.property(Alabel, A, Blabel, B, Clabel, C, ...
                                        paramLabel.HumidityRatio);
        end
        function propVals = CompressibilityFactor(obj, Alabel, A, Blabel, B, Clabel, C)
            paramLabel = obj.param;
            propVals = obj.property(Alabel, A, Blabel, B, Clabel, C, ...
                                        paramLabel.CompressibilityFactor);
        end
     end
     
     properties (Constant)
         param = struct('WetBulb','B', ...
                        'cp','C', ...
                        'cp_ha','Cha', ...
                        'DewPoint','D', ...
                        'Enthalpy','H', ...
                        'Enthalpy_ha','Hha', ...
                        'Conductivity','K', ...
                        'Viscosity','M', ...
                        'WaterMoleFraction','psi_w', ...
                        'Pressure','P', ...
                        'Pressure_water','P_w', ...
                        'RelativeHumidity','R', ...
                        'Entropy','S', ...
                        'Entropy_ha','Sha', ...
                        'DryBulb','T', ...
                        'Volume','V', ...
                        'Volume_ha','Vha', ...
                        'HumidityRatio','W', ...
                        'CompressibilityFactor','Z');
     end

     
     
end