# Usage and Project Structure

This document provides instructions on running simulations and describes the project file organization.

---

## Project Structure

### Libraries
- **Aerodynamics.slx** — Aerodynamic forces and moments generation  
- **Atmospheric.slx** — ISA atmospheric model for altitude-dependent air properties  
- **EqM.slx** — 6DOF equations of motion  
- **Propulsion.slx** — Engine thrust and propulsion system modeling  
- **Radiomaster_joystick_model.slx** — Joystick interface model for FlightGear integration

### Model
- **ACFT.slx** — Core 6DOF nonlinear aircraft model  
- **ACFTSim.slx** — Extended simulation model including FlightGear connection and sensors

### Results
Contains plots generated from simulation runs:
- Elevator and rudder doublet response plots (high and standard resolution)  
- Lateral phase-plane plots for stability analysis

### Testing
Subfolders supporting model validation and simulation:

- **Flight Test Matching/**  
  Contains flight test data and matching scripts to tune the simulation against real-world measurements. Includes before-and-after optimization plots.

- **Initialisation Scripts/**  
  Scripts for initializing aerodynamic coefficients for different flight regimes (low and high speed).

- **Scripts/**  
  Simulation scripts to perform trims, control input excitations, and response analyses.

- **Simulation/**  
  Scripts for running dynamic modes analysis and alternate simulation configurations.

- **Trim/**  
  Scripts to calculate trim conditions and to perform flight test matching for model validation.

---

## Running Simulations

1. **Initialize parameters**  
   Run initialization scripts from `Testing/Initialisation Scripts/` to set aerodynamic and propulsion parameters for desired flight conditions.

2. **Trim the aircraft**  
   Use trimming scripts in `Testing/Trim/` to compute steady-state conditions for your specified flight scenario.

3. **Run control input response simulations**  
   Execute scripts in `Testing/Scripts/` to simulate elevator and rudder doublets and generate response plots.

4. **Analyze dynamic modes**  
   Run `dynamic_modes.m` from `Testing/Simulation/` to linearize the model at trim points and extract eigenvalues, damping ratios, and mode frequencies.

---

## Visualization

- View generated plots in the `Results/` folder.  
- Use FlightGear integration in `ACFTSim.slx` for real-time 3D visualization (requires FlightGear installed and configured).

---

## Notes

- Ensure MATLAB, Aerospace Blockset, and Simulink Control Design toolboxes are installed.  
- Modify initialization files to tune the model for different aircraft configurations or flight conditions.

---

For any issues or feature requests, please open an issue or submit a pull request on GitHub.
