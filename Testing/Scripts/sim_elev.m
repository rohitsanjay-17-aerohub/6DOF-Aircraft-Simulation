%% ============================================================
%   Aircraft Model Trimmed Response Simulation - Full Template
%   For Simulink model: ACFT
%   ------------------------------------------------------------
%   This script performs:
%      - Extraction of trimmed input from opreport
%      - Preparation of simulation input signals
%      - Disturbance injection (Elevator doublet)
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
controlSurfaceName = 'ACFT/Elevator_deg';  
delta = 10;                    % Amplitude of doublet (deg)

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
t = [0 5 5.01 7 7.01 9 9.01 TF]; %step input
%t = [0 5 6 7 8 9 10 TF]; %ramp input     

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

%% 6️⃣ PLOTTING RESULTS

figure;
grid on;

subplot(421); 
plot(tout, yout(:, getIdx('ACFT/Alpha_deg')));
xlabel('Time [s]'); ylabel('Alpha [deg]');

subplot(422); 
plot(tout, yout(:, getIdx('ACFT/KCAS')));
xlabel('Time [s]'); ylabel('KCAS');

subplot(423); 
plot(tout, yout(:, getIdx('ACFT/Theta_deg')));
xlabel('Time [s]'); ylabel('Theta [deg]');

subplot(424); 
plot(t, ut(:, controlIdx+1));
xlabel('Time [s]'); ylabel('Elevator [deg]');

subplot(425); 
plot(tout, yout(:, getIdx('ACFT/q_degps')));
xlabel('Time [s]'); ylabel('Pitch Rate [deg/s]');

subplot(426); 
plot(tout, yout(:, getIdx('ACFT/Thrust_N')));
xlabel('Time [s]'); ylabel('Thrust [N]');

subplot(427); 
plot(tout, yout(:, getIdx('ACFT/PresAlt_ft')));
xlabel('Time [s]'); ylabel('Altitude [ft]');

subplot(428); 
plot(tout, yout(:, getIdx('ACFT/nz')));
xlabel('Time [s]'); ylabel('Load Factor [g]');

% Set figure size and title (optional)
set(gcf, 'Position', [100, 100, 1200, 800]);  % Optional: Make it wide and tall

% Create folder if it doesn't exist
if ~exist('Results', 'dir')
    mkdir('Results');
end

% Save the full figure
saveas(gcf, fullfile('Results', 'elevator_doublet_response.png'));

% Optional: for higher quality (for publication or GitHub embedding)
exportgraphics(gcf, fullfile('Results', 'elevator_doublet_response_highres.png'), 'Resolution', 300);
