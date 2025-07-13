function erro = minim2(K)
    global opreport ut p_FT r_FT

    % Modify Simulink variables
    assignin('base', 'Cn_r',    K(1));
    assignin('base', 'Cn_beta', K(2));
    assignin('base', 'Cn_rud',  K(3));

    % Get simulation duration
    TF = ut(end,1);

    % Run simulation
    [tout, xout, yout] = sim('ACFT', TF, ...
        simset('InitialState', getstatestruct(opreport), ...
               'Solver', 'ode4', 'FixedStep', 0.02), ut);

    % Get output index function
    outputNames = cell(size(opreport.Outputs, 1), 1);
    for i = 1:size(opreport.Outputs, 1)
        outputNames{i} = opreport.Outputs(i).Block;
    end
    getOutputIdx = @(name) find(strcmp(name, outputNames));

    % Error calculation
    r_sim = yout(:, getOutputIdx('ACFT/r_degps'));
    p_sim = yout(:, getOutputIdx('ACFT/p_degps'));

    erro = sum(sqrt(((r_sim - r_FT)/max(r_FT)).^2) + ...
               sqrt(((p_sim - p_FT)/max(p_FT)).^2));
end
