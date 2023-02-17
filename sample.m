% Include CoolPropLib and subdirectories to the Path (MATLAB> Home>
%  Environment> Set Path> Add with subfolders)

% Create Coolprop Handle
R245fa = CoolPropWrapper('R245fa')

% Set properties
% Suggests to CP to assume vapor phase
R245fa.setPhase('vap');
% Change EOS calculation method (default shown)
R245fa.setAbstractStateSrc(R245fa.EOS.BICUBIC_HEOS);

%% Output result as a matrix
R245fa.setOutputMode('mat')

% Use T, P
T = 60:2:100;
P = 120:10:230;

%% CASE1: Calculate density (T, P)
rho = R245fa.density('T',convertTemp('c','k',T),...
                     'P',P .* convert('kPa','Pa'));

[TT,PP] = meshgrid(T,P);
figure,
plot3(TT,PP,rho);
xlabel('Temperature [^\circC]')
ylabel('Pressure [kPa]')
zlabel('Density [kg/m^3]');

%% CASE2: Calculate Psat (T)
Psat = R245fa.PsatT(convertTemp('c','k',T));
figure,plot(T,Psat*convert('Pa','kPa'));
xlabel('Temperature [^\circC]')
ylabel('Pressure [kPa]')

%% Ouptut result as a vector
R245fa.setOutputMode('vec')

% Use a simulated random T measurement (aka large dataset)
T = randn(1E5,1)*2 + 36;

%% CASE3: Calculate enthalpy, assuming x=1 (x is q in CP)
h = R245fa.enthalpy('T', convertTemp('c','k',T), ...
                    'q', 1);
% Also show Psat
Psat = R245fa.PsatT(convertTemp('c','k',T)) .* convert('Pa','kPa');

figure,

subplot(2,1,1)
yyaxis left
plot(T)
xlabel('Time [arbituary]');
ylabel('Temperature [^\circC]')
yyaxis right
plot(Psat);
ylabel('Pressure [kPa]')

subplot(2,1,2)
plot(h)
xlabel('Time [arbituary]');
ylabel('Enthalpy [J/kg]');
