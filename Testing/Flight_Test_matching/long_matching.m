clear ut
global opreport ut elev theta u TF time_FT

%% 1. Load Flight Test Data
[NUM,TXT,RAW] = xlsread('Long_ft_data.xlsx');  % Make sure the file is in your MATLAB path
time_FT = NUM(:,1);     % Time [s], length corresponds to ~30 seconds total
elev = NUM(:,2);        % Elevator input [deg]
theta = NUM(:,3);       % Pitch angle [deg]
u = NUM(:,4);           % Forward speed [m/s]

% Ensure column vectors & consistent length
time_FT = time_FT(:);
elev = elev(:);
theta = theta(:);
u = u(:);

minLen = min([length(time_FT), length(elev), length(theta), length(u)]);
time_FT = time_FT(1:minLen);
elev = elev(1:minLen);
theta = theta(1:minLen);
u = u(1:minLen);

if any(diff(time_FT) <= 0)
    error('Flight test time vector must be strictly increasing.');
end

%% 2. Extract trimmed inputs from opreport
inputs = getinputstruct(opreport);
utin = zeros(length(inputs.signals),1);
for i = 1:length(inputs.signals)
    utin(i) = inputs.signals(i).values;
end

inputNames = {opreport.Inputs.Block};
getInputIdx = @(name) find(strcmp(name, inputNames));
ind_control = getInputIdx('ACFT/Elevator_deg');  % Elevator input index

%% 3. Create time-aligned input matrix for Simulink
dt = 0.02; % simulation step size
TF = max(time_FT); % total time ~30s
t = (0:dt:TF)';    % uniform time vector for simulation

% Interpolate elevator input to simulation time vector
elev_interp = interp1(time_FT, elev, t, 'linear', 'extrap');

% Initialize input matrix [time, inputs...]
ut = zeros(length(t), length(utin)+1);
ut(:,1) = t;
for i = 1:length(utin)
    ut(:,i+1) = utin(i); % fill all inputs with trimmed values initially
end
ut(:,ind_control+1) = elev_interp; % override elevator input with flight test data

%% 4. Simulate BEFORE Optimization
[tout, xout, yout] = sim('ACFT', TF, ...
    simset('InitialState', getstatestruct(opreport), ...
           'Solver', 'ode4', 'FixedStep', dt), ut);

%% 5. Plot and save BEFORE Optimization results
outputNames = {opreport.Outputs.Block};
getOutputIdx = @(name) find(strcmp(name, outputNames));

figure(1); clf; tiledlayout(3,2); set(gcf, 'Position', [100 100 1100 700]);
sgtitle('Longitudinal Matching – Before Optimization');

% Pitch angle theta
nexttile;
plot(tout, yout(:, getOutputIdx('ACFT/Theta_deg')), 'b', time_FT, theta, 'r--');
xlabel('Time [s]'); ylabel('\theta [deg]'); legend('Sim', 'Flight Test'); grid on;

% Forward speed u
nexttile;
plot(tout, yout(:, getOutputIdx('ACFT/u_mps')), 'b', time_FT, u, 'r--');
xlabel('Time [s]'); ylabel('Forward Speed [m/s]'); legend('Sim', 'Flight Test'); grid on;

% Pitch rate q
nexttile;
plot(tout, yout(:, getOutputIdx('ACFT/q_degps')), 'b');
xlabel('Time [s]'); ylabel('Pitch Rate [deg/s]'); grid on;

% Elevator input
nexttile;
plot(t, ut(:, ind_control+1), 'k');
xlabel('Time [s]'); ylabel('Elevator [deg]'); grid on;

% Altitude
nexttile;
plot(tout, yout(:, getOutputIdx('ACFT/PresAlt_ft')), 'b');
xlabel('Time [s]'); ylabel('Altitude [ft]'); grid on;

% Load factor Nz
nexttile;
plot(tout, yout(:, getOutputIdx('ACFT/nz')), 'b');
xlabel('Time [s]'); ylabel('Load Factor (Nz) [g]'); grid on;

% if ~exist('Results', 'dir'), mkdir('Results'); end
% exportgraphics(gcf, fullfile('Results', 'longitudinal_before_optimization.png'), 'Resolution', 300);

%% 6. Optimization - tune longitudinal stability derivatives: [Cm_q, Cm_alpha, Cm_elev]
options = optimset('Display','iter','MaxIter',300);

% Initial guess (must be in workspace, e.g., from your initialization file)
initial_guess = [Cm_q, Cm_alpha, Cm_elev]; 
lb = [-50, -5, -5];
ub = [0, 0, 0];

[K, FVAL] = fmincon(@minim, initial_guess, [], [], [], [], lb, ub, [], options);

assignin('base','Cm_q',     K(1));
assignin('base','Cm_alpha', K(2));
assignin('base','Cm_elev',  K(3));

fprintf('✅ Optimized longitudinal stability derivatives:\n');
fprintf('Cm_q = %.4f\nCm_alpha = %.4f\nCm_elev = %.4f\n', K(1), K(2), K(3));

%% 7. Simulate AFTER Optimization
[tout, ~, yout] = sim('ACFT', TF, ...
    simset('InitialState', getstatestruct(opreport), ...
           'Solver', 'ode4', 'FixedStep', dt), ut);

%% 8. Plot and save AFTER Optimization results
figure(2); clf; tiledlayout(3,2); set(gcf, 'Position', [100 100 1100 700]);
sgtitle('Longitudinal Matching – After Optimization');

% Pitch angle theta
nexttile;
plot(tout, yout(:, getOutputIdx('ACFT/Theta_deg')), 'b', time_FT, theta, 'r--');
xlabel('Time [s]'); ylabel('\theta [deg]'); legend('Sim', 'Flight Test'); grid on;

% Forward speed u
nexttile;
plot(tout, yout(:, getOutputIdx('ACFT/u_mps')), 'b', time_FT, u, 'r--');
xlabel('Time [s]'); ylabel('Forward Speed [m/s]'); legend('Sim', 'Flight Test'); grid on;

% Pitch rate q
nexttile;
plot(tout, yout(:, getOutputIdx('ACFT/q_degps')), 'b');
xlabel('Time [s]'); ylabel('Pitch Rate [deg/s]'); grid on;

% Elevator input
nexttile;
plot(t, ut(:, ind_control+1), 'k');
xlabel('Time [s]'); ylabel('Elevator [deg]'); grid on;

% Altitude
nexttile;
plot(tout, yout(:, getOutputIdx('ACFT/PresAlt_ft')), 'b');
xlabel('Time [s]'); ylabel('Altitude [ft]'); grid on;

% Load factor Nz
nexttile;
plot(tout, yout(:, getOutputIdx('ACFT/nz')), 'b');
xlabel('Time [s]'); ylabel('Load Factor (Nz) [g]'); grid on;

%exportgraphics(gcf, fullfile('Results', 'longitudinal_after_optimization.png'), 'Resolution', 300);
