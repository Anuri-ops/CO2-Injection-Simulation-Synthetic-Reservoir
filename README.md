# CO₂ Injection Simulation – Synthetic Oil Reservoir

This project simulates **gas injection represented as CO₂ into a 2D synthetic oil reservoir** using the MATLAB Reservoir Simulation Toolbox (MRST). It tracks the gas-saturation front over time and serves as a simple base case for gas-injection / enhanced-oil-recovery (EOR) workflow practice.

> **Scope note:** this is an oil-filled reservoir with a three-phase water–oil–gas formulation, not a saline-aquifer CO₂ storage model. The injected gas is represented with fixed fluid properties in an immiscible black-oil formulation. CO₂–brine dissolution, residual trapping, structural trapping, compositional effects and geochemical reactions are not modelled.

---

## Objective

To build practical familiarity with:

- Numerical reservoir simulation in MRST
- Three-phase black-oil formulations
- Injector / producer well controls
- Saturation-front visualisation
- Reproducible simulation setup in MATLAB

---

## Tools and Framework

- **MRST version:** 2025a
- **Modules:** `ad-core`, `ad-blackoil`, `mrst-gui`
- **Model:** `ThreePhaseBlackOilModel`
- **Simulation engine:** `simulateScheduleAD`
- **Language:** MATLAB

---

## Model Setup

| Parameter | Value |
|---|---|
| Grid | 60 × 40 cells |
| Domain | 600 × 400 m |
| Cell size | 10 × 10 m |
| Porosity | 0.20, homogeneous |
| Permeability | 100 mD, homogeneous |
| Initial pressure | 100 bar |
| Initial saturation | 100% oil (`Sw = 0, So = 1, Sg = 0`) |

---

## Fluids

The model uses `initSimpleADIFluid` with three phases and quadratic relative-permeability exponents (`n = [2, 2, 2]`).

| Phase | Viscosity (cP) | Density (kg/m³) |
|---|---:|---:|
| Water | 1 | 1000 |
| Oil | 5 | 700 |
| Gas (CO₂ proxy) | 0.05 | 600 |

These are simplified constant properties for a learning model, not a calibrated CO₂ PVT description.

---

## Well Configuration

The wells are placed using explicit logical-to-linear cell indexing with `sub2ind`:

- **Injector:** logical cell `(1, 1)` — lower-left corner
  - Rate-controlled at 100 m³/day
  - Injected composition: 100% gas
- **Producer:** logical cell `(60, 40)` — opposite corner
  - BHP-controlled at 50 bar

Using explicit linear cell indices avoids ambiguity when passing well locations to `addWell`.

---

## Simulation Details

- Total simulated time: 100 days
- 10 timesteps of 10 days
- Gas saturation displayed at each timestep

Key setup:

```matlab
nx = 60;
ny = 40;

injCell  = sub2ind([nx, ny], 1, 1);
prodCell = sub2ind([nx, ny], nx, ny);

state0 = initResSol(G, 100*barsa, [0 1 0]);

model = ThreePhaseBlackOilModel(G, rock, fluid, 'gas', true);

[wellSols, states] = simulateScheduleAD(state0, model, schedule);
```

---

## Result

The workflow visualises the evolution of gas saturation through the 100-day simulation.

The final-timestep image should be regenerated after running the corrected script. The script saves it as:

```text
images/co2_saturation_t10.png
```

---

## How to Run

1. Install MRST 2025a.
2. Place this repository somewhere writable.
3. Run `CO2InjectionSimulation.m`.
4. The script loads the required MRST modules, runs the schedule, displays the gas-saturation evolution and saves the final-timestep figure in `images/`.

---

## Limitations

- Homogeneous rock properties; no heterogeneity, layering or faults
- Immiscible black-oil treatment
- Fixed simplified fluid properties rather than calibrated CO₂ PVT behaviour
- No CO₂ dissolution into brine or oil
- No capillary pressure, hysteresis or residual trapping
- No compositional or miscibility effects
- No geomechanics, thermal effects or geochemical reactions
- Simple quadratic relative permeability rather than measured curves
- Qualitative saturation-front analysis only
- No history matching, uncertainty quantification, sweep-efficiency calculation or storage-capacity estimate

---

## Purpose

This is a **project-level reservoir-simulation exercise** built to develop practical MRST workflow competence. It is not presented as a calibrated field model or research result.

Possible extensions include:

- Heterogeneous permeability and porosity fields
- Recovery-factor and sweep-efficiency tracking
- Water-alternating-gas scheduling
- A separate brine-filled storage case with appropriate CO₂–brine physics
- Sensitivity analysis and uncertainty assessment

---

## Author

**Anuri Nwagbara**  
*Geological Engineer*
