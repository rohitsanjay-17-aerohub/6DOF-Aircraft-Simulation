clear ut
global opreport ut rud_FT p_FT r_FT outr out_ind TF
%% FLIGHT DATA (mass = 10886 / cg = 0.34 / KCAS = 240 / Alt = 35000ft - init_high)

%% --------------------------
% 1. Load Flight Test Data
% --------------------------
[NUM,TXT,RAW] = xlsread('ft_data2');
time_FT = NUM(:,1);     % Time [s]
rud_FT = NUM(:,2);      % Rudder input [deg]
beta_FT = NUM(:,3);     % Beta [deg]
p_FT = NUM(:,4);        % Roll rate [deg/s]
r_FT = NUM(:,5);        % Yaw rate [deg/s]

if any(diff(time_FT) <= 0)
    error('Flight test time vector must be strictly increasing.');
end

%% --------------------------
% 2. Aircraft Inertia Matrix (if needed for minim2)
% --------------------------
Ixx = 50400; Ixz = 16400; Iyy = 180000; Izz = 210000;
Inertia = [Ixx 0 -Ixz; 0 Iyy 0; -Ixz 0 Izz];

%% --------------------------
% 3. Extract Trimmed Inputs from opreport
% --------------------------
inputs = getinputstruct(opreport);
utin = zeros(length(inputs.signals),1);
for i = 1:length(inputs.signals)
    utin(i) = inputs.signals(i).values;
end

inputNames = {opreport.Inputs.Block};
getInputIdx = @(name) find(strcmp(name, inputNames));
ind_control = getInputIdx('ACFT/Rudder_deg');

%% --------------------------
% 4. Create Time-Aligned Input Matrix
% --------------------------
dt = 0.02;
TF = max(time_FT);
t = (0:dt:TF)';

rud_FT_interp = interp1(time_FT, rud_FT, t, 'linear', 'extrap');

ut = zeros(length(t), length(utin)+1);
ut(:,1) = t;
for i = 1:length(utin)
    ut(:,i+1) = utin(i);  % Fill with trim
end
ut(:,ind_control+1) = rud_FT_interp;

%% --------------------------
% 5. Simulate BEFORE Optimization
% --------------------------
[tout, xout, yout] = sim('ACFT', TF, ...
    simset('InitialState', getstatestruct(opreport), ...
           'Solver', 'ode4', 'FixedStep', dt), ut);

%% --------------------------
% 6. Plot and Save BEFORE Optimization Results
% --------------------------
outputNames = {opreport.Outputs.Block};
getOutputIdx = @(name) find(strcmp(name, outputNames));

figure(1); clf; tiledlayout(4,2); set(gcf, 'Position', [100 100 1200 800]);
title('Flight Test Comparison – Before Optimization');

nexttile; plot(tout, yout(:, getOutputIdx('ACFT/Beta_deg')), 'b', time_FT, beta_FT, 'r--');
xlabel('Time [s]'); ylabel('Beta [deg]'); legend('Sim', 'FT');

nexttile; plot(tout, yout(:, getOutputIdx('ACFT/KCAS'))); xlabel('Time [s]'); ylabel('KCAS');

nexttile; plot(tout, yout(:, getOutputIdx('ACFT/Phi_deg'))); xlabel('Time [s]'); ylabel('Phi [deg]');

nexttile; plot(t, ut(:, ind_control+1)); xlabel('Time [s]'); ylabel('Rudder [deg]');

nexttile; plot(tout, yout(:, getOutputIdx('ACFT/p_degps')), time_FT, p_FT, 'r--');
xlabel('Time [s]'); ylabel('Roll Rate [deg/s]'); legend('Sim', 'FT');

nexttile; plot(tout, yout(:, getOutputIdx('ACFT/r_degps')), time_FT, r_FT, 'r--');
xlabel('Time [s]'); ylabel('Yaw Rate [deg/s]'); legend('Sim', 'FT');

nexttile; plot(tout, yout(:, getOutputIdx('ACFT/PresAlt_ft'))); xlabel('Time [s]'); ylabel('Altitude [ft]');

nexttile; plot(tout, yout(:, getOutputIdx('ACFT/ny'))); xlabel('Time [s]'); ylabel('Load Factor [g]');

% Save plot
% exportgraphics(gcf, fullfile('Results', 'comparison_before_optimization_highres.png'), 'Resolution', 300);

figure(2); clf;
plot(yout(:, getOutputIdx('ACFT/Beta_deg')), yout(:, getOutputIdx('ACFT/Phi_deg')));
xlabel('Beta [deg]'); ylabel('Phi [deg]');
title('Beta vs Phi – Before Optimization');
% exportgraphics(gcf, fullfile('Results', 'beta_vs_phi_before_highres.png'), 'Resolution', 300);

%% --------------------------
% 7. Optimizer: Match only within flight test time window
% --------------------------
options = optimset('Display','iter','MaxIter',300);
initial_guess = [Cn_r, Cn_beta, Cn_rud];
lb = [-1, 0, -0.15]; ub = [0, 0.9, -0.03];

[K, FVAL] = fmincon(@minim2, initial_guess, [], [], [], [], lb, ub, [], options);

assignin('base','Cn_r', K(1));
assignin('base','Cn_beta', K(2));
assignin('base','Cn_rud', K(3));

fprintf('✅ Optimized lateral stability derivatives:\n');
fprintf('Cn_r = %.4f\nCn_Beta = %.4f\nCn_rud = %.4f\n', K(1), K(2), K(3));

%% --------------------------
% 8. Simulate AFTER Optimization (same time window)
% --------------------------
[tout, xout, yout] = sim('ACFT', TF, ...
    simset('InitialState', getstatestruct(opreport), ...
           'Solver', 'ode4', 'FixedStep', dt), ut);

%% --------------------------
% 9. Plot and Save AFTER Optimization
% --------------------------
figure(3); clf; tiledlayout(4,2); set(gcf, 'Position', [100 100 1200 800]);
title('Flight Test Comparison – After Optimization');

nexttile; plot(tout, yout(:, getOutputIdx('ACFT/Beta_deg')), 'b', time_FT, beta_FT, 'r--');
xlabel('Time [s]'); ylabel('Beta [deg]'); legend('Sim', 'FT');

nexttile; plot(tout, yout(:, getOutputIdx('ACFT/KCAS'))); xlabel('Time [s]'); ylabel('KCAS');

nexttile; plot(tout, yout(:, getOutputIdx('ACFT/Phi_deg'))); xlabel('Time [s]'); ylabel('Phi [deg]');

nexttile; plot(t, ut(:, ind_control+1)); xlabel('Time [s]'); ylabel('Rudder [deg]');

nexttile; plot(tout, yout(:, getOutputIdx('ACFT/p_degps')), time_FT, p_FT, 'r--');
xlabel('Time [s]'); ylabel('Roll Rate [deg/s]'); legend('Sim', 'FT');

nexttile; plot(tout, yout(:, getOutputIdx('ACFT/r_degps')), time_FT, r_FT, 'r--');
xlabel('Time [s]'); ylabel('Yaw Rate [deg/s]'); legend('Sim', 'FT');

nexttile; plot(tout, yout(:, getOutputIdx('ACFT/PresAlt_ft'))); xlabel('Time [s]'); ylabel('Altitude [ft]');

nexttile; plot(tout, yout(:, getOutputIdx('ACFT/ny'))); xlabel('Time [s]'); ylabel('Load Factor [g]');

% exportgraphics(gcf, fullfile('Results', 'comparison_after_optimization_highres.png'), 'Resolution', 300);

figure(4); clf;
plot(yout(:, getOutputIdx('ACFT/Beta_deg')), yout(:, getOutputIdx('ACFT/Phi_deg')));
xlabel('Beta [deg]'); ylabel('Phi [deg]');
title('Beta vs Phi – After Optimization');
% exportgraphics(gcf, fullfile('Results', 'beta_vs_phi_after_highres.png'), 'Resolution', 300);
