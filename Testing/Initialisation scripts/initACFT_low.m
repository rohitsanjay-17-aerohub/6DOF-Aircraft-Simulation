
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
CL0 = 0.19;
CL_alpha = 6.1879;
CL_elev = 0.4727;
CL_AlphaDot = 1.93;
CL_q = 4.66;
% Drag Coefficient Derivatives
CD0 = 0.0230;
CD_alpha = 0.1318;
CD_elev = 0.0178;
% Side force Coefficient Derivatives
CY_beta = -1.1803;
CY_rud = 0.4016;
CY_ail = 0;
CY_r = 0.910;
CY_p = 0.3;
% Rolling moment Derivatives
Cl_beta = -0.1352;
Cl_rud = 0.0289;
Cl_ail = -0.0516;
Cl_r = 0.100;
Cl_p = -0.45;
% Pitching moment Derivatives
Cm0 = 0.0133;
Cm_alpha = -2.0168;
Cm_elev = -1.6788;
Cm_AlphaDot = -6.76;
Cm_q = -36.3;
% Yawing moment Derivatives
Cn_beta = 0.1209;
Cn_rud = -0.1020;
Cn_ail = -6.3025e-4;
Cn_r = -0.30;
Cn_p = -0.114;

%Trimming
Trimming=0;
