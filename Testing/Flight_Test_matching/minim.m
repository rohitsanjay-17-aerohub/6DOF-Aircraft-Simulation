function erro = minim(K)
    global opreport ut theta

    % Assign the tuning parameters for Simulink workspace
    assignin('base', 'Cm_q',    K(1));
    assignin('base', 'Cm_alpha', K(2));
    assignin('base', 'Cm_elev',  K(3));

    TF = ut(end,1);

    % Run simulation with current parameters
    [tout, ~, yout] = sim('ACFT', TF, ...
        simset('InitialState', getstatestruct(opreport), ...
               'Solver', 'ode4', 'FixedStep', 0.02), ut);

    % Extract output names
    outputNames = cell(size(opreport.Outputs, 1), 1);
    for i = 1:size(opreport.Outputs, 1)
        outputNames{i} = opreport.Outputs(i).Block;
    end
    getOutputIdx = @(name) find(strcmp(name, outputNames));

    % Extract simulated pitch angle theta
    theta_sim = yout(:, getOutputIdx('ACFT/Theta_deg'));

    % Interpolate flight test theta to simulation time vector
    theta_FT_interp = interp1(ut(:,1), theta, tout, 'linear', 'extrap');

    % Normalize to avoid scaling issues
    norm_theta = max(abs(theta_FT_interp));
    if norm_theta == 0
        norm_theta = 1;
    end

    % Error is sum of squared normalized differences of theta only (can extend later)
    erro = sum(((theta_sim - theta_FT_interp)/norm_theta).^2);
end
