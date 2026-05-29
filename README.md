<div align="center">

# EGH490 Research Project

## Investigation into Slot Arrays Radiating Through Truncated Waveguides

### Suppression of Second-Order Lobes in Waveguide Antenna Systems

**Queensland University of Technology (QUT)**
School of Electrical Engineering and Robotics

**Student Engineer:** Chabod Masere
**Supervisor:** Dr Jacob Coetzee

<br>

<p align="center">
  <img src="https://github.com/user-attachments/assets/f2285881-ba32-41f4-9f53-913a6bd0cb83" width="560" alt="Ordered second-order lobes radiation pattern"/>
</p>

<br><br>

**Project Status:** Completed
**Research Focus:** Electromagnetic Field Theory · CST Simulation · Slot-Admittance Modelling · Array Synthesis · Prototype Validation

</div>

---

## Overview

This repository documents the research, modelling, simulation, design, prototyping, and validation work completed for the **EGH490 Research Project** at the **Queensland University of Technology (QUT)**.

The project investigated the effectiveness of **arrays of slots radiating through truncated waveguides** as a method for suppressing unwanted **second-order lobes** in antenna radiation patterns. These lobes arise when the aperture field distribution departs from the ideal excitation profile, causing power to radiate into unintended directions and reducing beam purity, gain efficiency, and angular discrimination.

The completed work represents a full engineering research workflow, progressing from single-slot electromagnetic behaviour to array-level synthesis, CAD development, physical prototyping, and validation-oriented analysis.

---

## Research Aim

The central aim of this project was to determine whether controlled slot placement and cavity-backed/truncated waveguide geometry could reduce second-order lobe formation while maintaining acceptable impedance matching and radiation performance.

The project focused on:

* Understanding slot excitation in rectangular waveguides
* Modelling the relationship between slot offset, resonance, and self-admittance
* Investigating cavity-backed slot behaviour
* Evaluating aperture field uniformity in amplitude and phase
* Suppressing second-order lobes in the far-field radiation pattern
* Translating simulated geometry into manufacturable prototypes
* Validating analytical and simulated predictions through structured design iteration

---

## Technical Background

Waveguide slot arrays are widely used in radar, aerospace, satellite communication, and high-frequency antenna systems due to their high efficiency, mechanical robustness, and ability to generate controlled radiation patterns.

However, truncated waveguide structures and non-ideal aperture distributions can produce unwanted radiation peaks. These second-order lobes may arise due to:

* Abrupt aperture truncation
* Non-uniform slot excitation
* Phase error across the slot array
* Mutual coupling between neighbouring slots
* Higher-order field behaviour inside the waveguide or cavity
* Poorly controlled slot spacing, offset, or geometry

This project investigated these effects using a combined analytical, numerical, and prototype-driven workflow.

---

## Methodology

The research followed a structured engineering process:

### 1. Literature Review

Review of waveguide slot arrays, cavity-backed slots, truncated apertures, sidelobe suppression, and array synthesis methods.

### 2. Single-Slot Modelling

Development of single-slot CST models to study resonance, self-admittance, slot offset, slot length, and coupling behaviour.

### 3. Parametric Sweeps

Systematic variation of slot and cavity parameters, including offset, length, width, cavity size, and truncation geometry.

### 4. Admittance Extraction

Extraction and comparison of conductance and susceptance behaviour to identify resonant slot configurations.

### 5. Aperture Field Analysis

Investigation of electric field magnitude and phase distribution across the slot and cavity aperture.

### 6. Array Synthesis

Extension from single-slot behaviour to multi-slot array behaviour using excitation control and array-factor principles.

### 7. Radiation Pattern Evaluation

Assessment of gain, directivity, sidelobe levels, and second-order lobe suppression.

### 8. CAD Development and Prototype Fabrication

Translation of simulated waveguide and slot-array geometries into manufacturable CAD models. Prototype components were developed for additive manufacturing using a **Bambu Lab X1C Carbon 3D printer**, enabling rapid iteration of waveguide bodies, cavity layers, and slot-array structures.

### 9. Validation and Verification

Comparison of simulation results with measurement-oriented expectations, including S-parameter behaviour, impedance characteristics, aperture-field behaviour, and radiation pattern performance.

---

## Technical Scope

This repository includes work related to:

* Rectangular waveguide theory
* TE-mode field behaviour
* Slot excitation mechanisms
* Slot self-admittance
* Equivalent circuit modelling
* Series impedance and shunt admittance representations
* Slot offset and resonance behaviour
* Cavity-backed slot analysis
* Mutual coupling considerations
* Array-factor modelling
* Far-field radiation pattern analysis
* CST Microwave Studio simulation
* MATLAB post-processing
* Fusion 360 CAD development
* Bambu Lab X1C Carbon additive manufacturing
* Prototype preparation for experimental validation

---

## Repository Structure

```text
EGH490-Research-Project/
│
├── README.md
├── TODO.md
├── .gitignore
├── desktop.ini
├── Honours_Submission.pdf
│
├── Compiled_Data/
│   └── Processed and compiled simulation outputs, extracted datasets, and finalised numerical results.
│
├── Graphical_Images/
│   └── General graphical assets used for README presentation, report figures, diagrams, and visual documentation.
│
├── Multiarray_Extracts/
│   └── Extracted data and results associated with multi-slot and array-level waveguide configurations.
│
├── Relevant_Research_Papers/
│   └── Literature, supporting academic papers, and reference material used throughout the research project.
│
└── Waveguide_Images/
    └── CST exports, waveguide model images, antenna geometry visuals, radiation patterns, and prototype-related imagery.
```

## Key Engineering Questions

This project was structured around several core engineering questions:

* How does slot offset affect resonant conductance and susceptance?
* How does a cavity-backed configuration modify the active slot admittance?
* Can cavity geometry improve aperture field uniformity?
* How much phase variation across the aperture is acceptable before radiation performance degrades?
* What geometric parameters most strongly influence second-order lobe formation?
* Can a truncated waveguide slot array achieve meaningful lobe suppression while remaining manufacturable?
* How effectively can additive manufacturing support early-stage waveguide antenna prototyping?
* How closely can CST simulation predictions be aligned with analytical expectations and physical prototype behaviour?

---

## Simulation, Design, and Fabrication Tools

The project used a combination of electromagnetic simulation, numerical analysis, CAD modelling, and additive manufacturing tools:

| Tool                     | Purpose                                                                                |
| ------------------------ | -------------------------------------------------------------------------------------- |
| CST Microwave Studio     | Full-wave electromagnetic simulation and parametric sweeps                             |
| MATLAB                   | Data analysis, radiation pattern plotting, array-factor modelling, and post-processing |
| Fusion 360               | CAD modelling and prototype preparation                                                |
| Bambu Lab X1C Carbon     | Additive manufacturing of prototype waveguide and slot-array components                |
| GitHub                   | Version control, research documentation, and artefact management                       |
| VNA Testing              | S-parameter measurement and impedance validation                                       |
| Anechoic Chamber Testing | Radiation pattern validation and lobe-level characterisation                           |

---

## Prototype Development

A major component of this completed research was the transition from simulated electromagnetic models to physical prototype geometries.

The prototype workflow involved:

* Exporting waveguide and slot-layer geometries from CAD
* Preparing print-ready files for additive manufacturing
* Fabricating early-stage prototypes using the **Bambu Lab X1C Carbon**
* Assessing physical geometry, tolerances, slot definition, and assembly fit
* Using printed prototypes to support design iteration before final metallic fabrication

The use of additive manufacturing enabled rapid evaluation of complex truncated waveguide geometries before committing to more expensive metallic manufacturing processes.

---

## Expected Performance Criteria

The project used the following performance indicators to assess design quality:

* Reduction of second-order lobes relative to the main beam
* Target suppression near or below **−20 dB** where achievable
* Acceptable impedance matching at the feed point
* Stable resonant behaviour across selected slot configurations
* Controlled aperture amplitude and phase distribution
* Manufacturable waveguide and slot-layer geometry
* Prototype geometry suitable for fabrication and experimental testing
* Agreement between analytical trends and CST simulation outputs

---

## Research Contributions

This repository contributes a structured workflow for analysing and designing truncated waveguide slot arrays. The main contributions include:

* A single-slot simulation database for offset and geometry sensitivity
* Comparative admittance analysis of conventional and cavity-backed slot models
* Investigation of aperture field uniformity as a design metric
* Transition from single-slot behaviour to array-level synthesis
* CAD-ready waveguide and slot-layer concepts for prototyping
* Additively manufactured prototype iterations using the Bambu Lab X1C Carbon
* Documentation of a completed honours-level antenna engineering research process

---

## Academic Context

| Item             | Description                                      |
| ---------------- | ------------------------------------------------ |
| Unit             | EGH490 Research Project                          |
| Institution      | Queensland University of Technology              |
| School           | Electrical Engineering and Robotics              |
| Research Area    | Antennas, waveguides, electromagnetic simulation |
| Supervisor       | Dr Jacob Coetzee                                 |
| Student Engineer | Chabod Masere                                    |
| Project Status   | Completed                                        |

---

## Status

**Project completed.**

This repository serves as a technical archive of the completed project’s engineering development, including theoretical modelling, CST simulations, MATLAB analysis, CAD development, prototype fabrication, and final documentation.

The work reflects the progression from electromagnetic field theory to simulated design, physical prototyping, and validation-oriented antenna engineering.

---

<div align="center">

## Field Theory → Simulation → Slot Admittance → CAD Prototyping → Array Synthesis → Validation

</div>
