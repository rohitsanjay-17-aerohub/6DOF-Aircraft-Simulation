%% ============================================================
%   Aircraft Model Trimmed Response Simulation - Full Template
%   For Simulink model: ACFT
%   ------------------------------------------------------------
%   This script performs:
%      - Extraction of trimmed input from opreport
%      - Preparation of simulation input signals
%      - Disturbance injection (Rudder doublet here)
%      - Simulation run using ode4 fixed-step solver
%      - Automatic output extraction & plotting
% =============================================================

%% 1️⃣ USER SETTINGS

% Simulink model name
modelName = 'ACFT';

% Time of simulation
TF = 100;                      % Total time of simulation [s]

% Solver settings
solverType = 'ode4';           % Fixed step RK4
fixedStep = 0.01;              % Step size [s]

% Control surface to excite
controlSurfaceName = 'ACFT/Rudder_deg';  
delta = 5;                    % Amplitude (deg)

% NOTE: opreport must be previously generated using trim function.
% For example:
% [opreport, op_point] = trim('ACFT',...); 
% In this code, we assume opreport is already loaded.

%% 2️⃣ EXTRACT TRIMMED INPUTS FROM OPREPORT

% Extract trimmed inputs from opreport using getinputstruct
inputs = getinputstruct(opreport);   

% Pre-allocate initial input values vector (trimmed inputs)
utin = zeros(size(inputs.signals,2),1);
for i = 1:size(inputs.signals,2)
    utin(i) = inputs.signals(i).values;
end

% Extract list of input names (block paths) directly from opreport
inputBlocks = strtrim({opreport.Inputs.Block}');  % Trim spaces

% Find index for the specific control surface you want to disturb
controlIdx = find(strcmp(controlSurfaceName, inputBlocks));

%% 3️⃣ CREATE SIMULATION INPUT TIME HISTORY

% Time vector for simulation
t = [0 5 5.01 7 7.01 9 9.01 TF];
% t = [0 5 6 7 8 9 10 TF];      

% Initialize full input signal matrix (Simulink expects: [time inputs])
ut = zeros(length(t), length(utin)+1);  
ut(:,1) = t';  % First column: time

% Fill input values (using trim values) for all time steps
for i = 1:length(utin)
    ut(:,i+1) = utin(i);  
end

% Apply control disturbance (elevator doublet in this example)
ut(:, controlIdx+1) = [ut(1,controlIdx+1) ut(1,controlIdx+1) ...
    (ut(1,controlIdx+1)-delta) (ut(1,controlIdx+1)-delta) ...
    (ut(1,controlIdx+1)+delta) (ut(1,controlIdx+1)+delta) ...
    ut(1,controlIdx+1) ut(1,controlIdx+1)]';

%% 4️⃣ RUN SIMULATION

% Run the Simulink model using initial conditions from opreport
[tout, xout, yout] = sim(modelName, TF, ...
    simset('InitialState', getstatestruct(opreport), ...
           'Solver', solverType, 'FixedStep', fixedStep), ut);

%% 5️⃣ EXTRACT OUTPUT SIGNAL NAMES FROM OPREPORT

% Extract trimmed output names from opreport
outputBlocks = strtrim({opreport.Outputs.Block}');

% Define helper function to get output index by name
getIdx = @(blockName) find(strcmp(blockName, outputBlocks));


% Create first figure: Rudder doublet response
fig1 = figure;
grid on;
subplot(421);
plot(tout,yout(:,getIdx('ACFT/Beta_deg')));
xlabel('Time [s]'); ylabel('Beta [deg]');

subplot(422);
plot(tout,yout(:,getIdx('ACFT/KCAS')));
xlabel('Time [s]'); ylabel('KCAS [mps]');

subplot(423);
plot(tout,yout(:,getIdx('ACFT/Phi_deg')));
xlabel('Time [s]'); ylabel('Phi [deg]');

subplot(424);
plot(t,ut(:,controlIdx+1));
xlabel('Time [s]'); ylabel('Rudder [deg]');

subplot(425);
plot(tout,yout(:,getIdx('ACFT/p_degps')));
xlabel('Time [s]'); ylabel('Roll rate [deg/s]');

subplot(426);
plot(tout,yout(:,getIdx('ACFT/r_degps')));
xlabel('Time [s]'); ylabel('Yaw rate [deg/s]');

subplot(427);
plot(tout,yout(:,getIdx('ACFT/PresAlt_ft')));
xlabel('Time [s]'); ylabel('Altitude [ft]');

subplot(428);
plot(tout,yout(:,getIdx('ACFT/ny')));
xlabel('Time [s]'); ylabel('LoadFactor [ny]');
sgtitle('Rudder Doublet Response');

% To create separate figure for Beta vs Phi phase plot
fig2 = figure;
plot(yout(:,getIdx('ACFT/Phi_deg')), yout(:,getIdx('ACFT/Beta_deg')), 'b-', 'LineWidth', 1.5);
xlabel('Phi [deg]');
ylabel('Beta [deg]');
title('Lateral Phase Plane: Beta vs Phi');
grid on;
axis equal


% Create folder if it doesn't exist
if ~exist('Results', 'dir')
    mkdir('Results');
end

% Save both figures
saveas(fig1, fullfile('Results', 'rudder_doublet_response.png'));
exportgraphics(fig1, fullfile('Results', 'rudder_doublet_response_highres.png'), 'Resolution', 300);

saveas(fig2, fullfile('Results', 'lateral_phase_plane.png'));
exportgraphics(fig2, fullfile('Results', 'lateral_phase_plane_highres.png'), 'Resolution', 300);


