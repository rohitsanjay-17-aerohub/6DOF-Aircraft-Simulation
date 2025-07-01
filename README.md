# 6DOF-Aircraft-Simulation
Full nonlinear aircraft model in Simulink with trim and response plots

Trimming Conditions Used:
Longitudinal Steady State Trim 
- If defined speed increases, we can see decrease in angle of attack and increase in thrust, throttle position.
- For climbing with gamma being set, we can see increase in thrust, throttle position and negative derivative in the z direction.
- For a given throttle and speed, the gamma will float to find a steady state condition.
- Similarly for given throttle and gamma, the speed will float.
- When banking angle(Phi_deg) is defined we can see change in heading angle(PSI_rad) and changes to the elevator, aileron, and rudder angles as well as change in load factor(nz). 

Elevator/Rudder Doublet Plots:
- Elevator doublet is given to analyse the short period oscillation and Phugoid oscillation.
- Rudder doublet is given to analyse 

Dynamic modes analysis:
- The Longitudinal steady state trimmed model is linearized to obtain the state space form.
- The state space is then used to analyse the dynamic behaviour of the aircraft both longitudinally and laterally by the looking at the effects of
short period oscillations, phugoid and dutch roll.
- The longitudinal states taken for the analysis are q_radps, u_mps, v_mps, Theta_mps, ZI_m. The lateral states of relevance are p_radps, r_radps, v_mps, Phi_rad and Psi_rad.
- The Longitudinal and lateral states eigen values lets us understand the stability of the system. For example if the complex eigen value has pure negative value it is in stable
non oscillatory mode and if pure positive value then it is in unstable non oscillatory mode. If the eigen value is with negative real part and complex conjugate then stable
oscillatory motion and vice versa.
- The second order system is considered to get the frequency and damping of the oscillations.


Assumptions:
No wind forces are used.
GroundForces are zero since aircraft altitude will be defined.
