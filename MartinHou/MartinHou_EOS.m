
% The Martin-Hou EOS uses English units.




% ------------------------------
% MH EOS constants

% Fluid properties
MW = 200.0;         % g/mol
Tc = 787.86;        % R
Pc = 359.506;       % psia
vc = 0.03014;       % ft3/lbm
Zc = Pc*vc/R/Tc;
Triple = 450;       % R
R = 0.05369;   % psia-ft3/lbm-R

% A,B,C,beta as given
A = [0, -3.11951, 1.27563E-01, -5.32475E-04, 0, 0];
B = [R, 1.68458E-03, -1.10834E-04, 0, 3.77983E-09, 0];
C = [0, -44.33361, 1.37235, 0, -1.22939E-04, 0];

b = 2.92883E-03;


% let c5 = 0
C(5) = 0;


% Calculated properties
rho_l_const = struct('a',3.012864E+01 , ...
                     'b',1.141271E+02 , ...
                     'c',-2.022943E+02, ...
                     'd',4.175785E+02 , ...
                     'e',-3.127115E+02, ...
                     'f',0            , ...
                     'g',9.406709E+01);
P_g_const = struct('a', -7.695856E+03, ...
                   'b', 2.132922E+01 , ...
                   'c', -1.197082E-02, ...
                   'd', 0            , ...
                   'e', 6.060697E-06);
href = 18.2287;     % based of 300 K saturated vapor
sref = -0.343115;   %

%
% ------------------------------

% query
% T_SI = 40;
T_IP = convertTemp('C','R',T_SI);

%V_SI = (5E-4:1E-6:0.12);
V_IP = V_SI.*convert('m3/kg', 'ft3/lbm');


f = f_MH(A,B,C,Tc,T_IP);                %   (syms) MH_EOS subfunctions
n = 1:length(f);                        %   n terms


P_IP = sum((f./(V_IP-b)'.^n).');        %   EOS
P_SI = P_IP .* convert('psia','Pa');


function f = f_MH(A,B,C,Tc,T)
    f = A + B.*T + C.*exp(-5.475.*T./Tc);
end

function rho_l = rho_l_fh(const, T, Tc)
% rho_l_fh  liquid density[=]lbm/ft3
%   T[] = Tc[]
%   rho_l[=]lbm/ft3

    Tz = 1-T./Tc;
    rho_l =   const.a ...
            + const.b .* Tz.^(1/3) ...
            + const.c .* Tz.^(2/3) ...
            + const.d .* Tz ...
            + const.e .* Tz.^(2/3) ...
            + const.f .* Tz.^(1/2) ...
            + const.g .* Tz.^2;
end

function P_g = P_g_fh(const, T, Tc)
% P_g_fh    vapor pressure fit
% T         Temperature [R]
% Tc        Critical temperature [R]

    ln_P_g =    const.a ./ T ...
              + const.b ...
              + const.c .* T ...
              + const.d .* (1-T./Tc).^1.5 ...
              + const.e .* T.^2;
    P_g = exp(ln_P_g);
end

function c_v_0 = c_v_0_fh(const, T)
% c_v_0_fh  specific heat, P=0
%   T[=]R
%   c_v_0[=] Btu/lb-R

    c_v_0 =	  const.a ...
            + const.b .* T ...
            + const.c .* T.^2 ...
            + const.d .* T.^3 ...
            + const.e ./ T.^2;
end
        

