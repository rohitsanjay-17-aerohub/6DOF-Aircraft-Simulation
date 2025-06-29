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

Assumptions:
No wind forces are used.
GroundForces are zero since aircraft altitude will be defined.
