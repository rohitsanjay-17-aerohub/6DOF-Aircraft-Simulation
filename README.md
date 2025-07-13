# ✈️ Modeling and Simulation of a 6DOF Aircraft

This model shows a fixed-wing aircraft performing steady-state trim and dynamic response analysis using Simulink® and Aerospace Blockset™. The simulation includes a full 6-degrees-of-freedom (6DOF) nonlinear rigid-body model with aerodynamic, propulsion, and flight control elements. The aircraft is trimmed to specified flight conditions and excited with control surface inputs to evaluate its dynamic behavior. The model also enables linearization and eigenmode analysis to study short-period, phugoid, and Dutch roll modes.

---

## Key Components

This model uses the following key components to model and analyze the aircraft:

- **ISA Atmospheric Model** for air property variation with altitude (Requires Aerospace Blockset™)  
- **Aerodynamic Forces and Moments** modeled using control surface deflections and stability derivatives  
- **6DOF Equations of Motion** in body axes for full rigid-body dynamics  
- **Throttle-Based Propulsion System** to simulate thrust generation and power control  
- **Control Surface Inputs:** Elevator, aileron, and rudder configured for doublet excitation and manual control  
- **Trim Analysis** to compute steady-state flight conditions for specified inputs  
- **Model Linearization** to obtain a state-space system for control design and mode analysis  

---

## 🎯 Trim Conditions and Flight Scenarios

The aircraft model is trimmed to various flight conditions using Simulink Control Design tools. Depending on which inputs are fixed or free, the system computes steady-state values that satisfy the equations of motion:

- **Defined airspeed:** Results in decreased angle of attack and increased thrust  
- **Defined flight path angle (γ):** Leads to increased throttle and negative vertical velocity  
- **Floating γ or airspeed:** Solver determines steady-state based on available inputs  
- **Defined bank angle (ϕ):** Causes a change in heading (ψ) and trim adjustments in elevator, aileron, and rudder, along with load factor (nz) changes  

---

## Elevator/Rudder Doublet Plots

- Elevator doublet is applied to analyse short period and phugoid oscillations.  
- Rudder doublet is applied to analyse lateral-directional dynamics (e.g., Dutch roll).  

---

## 📊 Control Input Excitation and Response Analysis

To analyze dynamic behavior, control surface doublet inputs are applied:

- **Elevator doublet:** Used to excite short-period and phugoid longitudinal oscillations  
- **Rudder doublet:** Used to excite lateral-directional dynamics such as Dutch roll  

The model outputs plots of state responses over time, highlighting damping characteristics and natural frequencies of dominant modes.

---

## 🧮 Dynamic Modes and Linear Analysis

The nonlinear aircraft model is linearized about a trimmed operating point. The resulting state-space system is used to evaluate stability and mode shapes:

- **Longitudinal States:** `q_radps`, `u_mps`, `v_mps`, `Theta_rad`, `ZI_m`  
- **Lateral States:** `p_radps`, `r_radps`, `v_mps`, `Phi_rad`, `Psi_rad`  

Eigenvalue analysis reveals dynamic characteristics:

- Real, negative eigenvalues → Stable, non-oscillatory modes  
- Real, positive eigenvalues → Unstable, non-oscillatory modes  
- Complex conjugates → Oscillatory modes (stability based on sign of real part)  

Second-order approximations are used to compute damping ratios and natural frequencies of key modes, including:

- Short-period and phugoid (longitudinal)  
- Dutch roll and spiral divergence (lateral)  

---

## ⚙️ Assumptions

- No wind or gust disturbances modeled  
- Ground forces disabled (`GroundForces = 0`) – aircraft assumed airborne throughout  
- Engine modeled as steady-state thrust source without transient delay  
- Symmetric aircraft configuration  
