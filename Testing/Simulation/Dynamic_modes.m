model = 'ACFT';
linsys = linearize(model, opreport);  % Linearize the model around the trim point

% Create a function handle for index lookup
getIdx = @(name) find(strcmp(name, linsys.StateName));

% Longitudinal States: x = [q; u; w; theta; Zdist]
ind_long = [getIdx('q_radps');
            getIdx('u_mps');
            getIdx('w_mps');
            getIdx('THETA_rad');
            getIdx('ZI_m')];

Along = linsys.A(ind_long, ind_long);  % Extract longitudinal A matrix

LONG_EIG = eig(Along);
LongData = LONG_EIG;  % All longitudinal eigenvalues

% Lateral-Directional States: x = [p; r; v; phi; psi]
ind_lat = [getIdx('p_radps');
           getIdx('r_radps');
           getIdx('v_mps');
           getIdx('PHI_rad');
           getIdx('PSI_rad')];

Alat = linsys.A(ind_lat, ind_lat);  % Extract lateral A matrix

LAT_EIG = eig(Alat);
LatData = LAT_EIG(2:end);  % Exclude first eigenvalue (non-relevant)

% Longitudinal modes damping and frequency
[Wn_long, Z_long] = damp(LongData);

disp(['Short Period Frequency: ', num2str(Wn_long(2)), ' rad/s'])
disp(['Short Period Damping: ', num2str(Z_long(2))])
disp(['Phugoid Frequency: ', num2str(Wn_long(4)), ' rad/s'])
disp(['Phugoid Damping: ', num2str(Z_long(4))])

% Lateral-directional modes damping and frequency
[Wn_lat, Z_lat] = damp(LatData);

disp(['Dutch Roll Frequency: ', num2str(Wn_lat(2)), ' rad/s'])
disp(['Dutch Roll Damping: ', num2str(Z_lat(2))])

% Spiral mode time to double or half depending on stability
spiral_real_idx = find(imag(LatData)==0);
if real(max(LatData(spiral_real_idx))) > 0
    disp(['Spiral Stability time to double: ', ...
        num2str(log(2)*abs(1/(Wn_lat(spiral_real_idx(end))*Z_lat(spiral_real_idx(end))))), ' s'])
else
    disp(['Spiral Stability time to half: ', ...
        num2str(log(2)*abs(1/(Wn_lat(spiral_real_idx(end))*Z_lat(spiral_real_idx(end))))), ' s'])
end

% Roll mode time to half
roll_real_idx = find(real(LatData) == min(real(LatData)));
disp(['Roll Mode time to half: ', ...
    num2str(log(2)*abs(1/(Wn_lat(roll_real_idx)*Z_lat(roll_real_idx)))), ' s'])
