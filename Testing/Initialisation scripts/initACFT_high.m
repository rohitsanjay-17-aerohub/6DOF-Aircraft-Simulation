% Mass properties
Ixx = 100000;                                                               % kg.m2
Iyy = 230000;                                                               % kg.m2
Izz = 280000;                                                               % kg.m2
Ixz = 23000;                                                                % kg.m2
Inertia = [Ixx 0 -Ixz; 0 Iyy 0; -Ixz 0 Izz];                                % Inertia tensor
y_cg = 0;                                                                   % m (+ is to the right of ref. plane)
z_cg = -0.4;                                                                % m (+ is below the ref. plane)
g = 9.80665;                                                                % m/s2

% Engine Data
V_reference_mps = 200;                                                      % m/s
rho_reference_kgpm3 = 1.225;                                                % kg/m3
nv = 0;
nrho = 0.75;
alfaf_deg = -1.8;                                                           % Thrust angle - deg
xf_m = -3.8;                                                                % Enigne distance on x axis from approximate CG position - m (+ is FWD of the CG)
zf_m = -0.6;                                                                % Enigne distance on z axis from approximate CG position - m (+ is below the ref. plane)
Tmax = 68000;                                                               % Thrust - N

% Aircraft Data
S = 45;                                                                     % Wing Area - m2
c = 2.5;                                                                    % Mean Aerodynamic Chord - m
b = 21;                                                                     % Wing Span - m

% Aerodynamic Data

% Lift Coefficient Derivatives
CL0 = 0.209;
CL_alpha = 8.7491;
CL_elev = 0.5380;
CL_AlphaDot = 1.27;
CL_q = 4.14;
% Drag Coefficient Derivatives
CD0 = 0.0351;
CD_alpha = 0.5157;
CD_elev = 0.0178;
% Side force Coefficient Derivatives
CY_beta = -1.2777;
CY_rud = 0.4343;
CY_ail = 0;
CY_r = 0.910;
CY_p = 0.300;
% Rolling moment Derivatives
Cl_beta = -0.1352;
Cl_rud = 0.0333;
Cl_ail = -0.0453;
Cl_r = 0.100;
Cl_p = -0.45;
% Pitching moment Derivatives
Cm0 = 0.000;
Cm_alpha = -2.6351;
Cm_elev = -1.9079;
Cm_AlphaDot = -4.53;
Cm_q = -37.6;
% Yawing moment Derivatives
Cn_beta = 0.1478;
Cn_rud = -0.1100;
Cn_ail = -8.5944e-04;
Cn_r = -0.5;
Cn_p = -0.114;

%Trimming
Trimming=0;