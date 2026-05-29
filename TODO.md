# 📡 Waveguide Slot Array — MASTER TODO (Single File)

---

## 🔹 0. Objective

- [ ] Build a longitudinal waveguide slot array
- [ ] Use CST single-slot data → synthesize full array
- [ ] Suppress second-order lobes (not just sidelobes)

---

## 🔹 1. CST Single-Slot Setup

- [ ] Create single-slot model in CST (waveguide + longitudinal slot)
- [ ] Define parameters:
  - [ ] Offset: `x`
  - [ ] Length: `L`
- [ ] Fix:
  - [ ] Frequency
  - [ ] Waveguide dimensions
- [ ] Set frequency domain solver

---

## 🔹 2. Parameter Sweeps

- [ ] Sweep `x` over valid range (e.g. centre → near wall)
- [ ] For each `x`, sweep `L`
- [ ] Ensure sufficient resolution (don’t undersample)

---

## 🔹 3. Export Data

- [ ] Export `S11` for all runs
- [ ] (Optional) export `S21`
- [ ] Export far-field pattern (element pattern)

---

## 🔹 4. Compute Slot Admittance

- [ ] Import data into MATLAB / Python / C++
- [ ] Convert:

- [ ] Extract:
- [ ] `G_self = Re(Y/Y0)`
- [ ] `B_self = Im(Y/Y0)`

---

## 🔹 5. Find Resonant Points (CRITICAL)

For each offset `x`:

- [ ] Plot `B_self vs L`
- [ ] Find:

- [ ] At that point, record:
- [ ] `x`
- [ ] `L_res`
- [ ] `G_self(x)`

---

## 🔹 6. Build Core Dataset

- [ ] Create table:


- [ ] Verify:
- [ ] Smooth behaviour
- [ ] Monotonic increase of G with x

---

## 🔹 7. Fit Continuous Model

- [ ] Interpolate:


- [ ] Validate:
- [ ] No discontinuities
- [ ] Physically reasonable trends

---

## 🔹 8. Define Array Parameters

- [ ] Compute guided wavelength:


- [ ] Choose spacing:


- [ ] Choose number of slots `N`

---

## 🔹 9. Choose Amplitude Distribution

- [ ] Select taper:
- [ ] Taylor (recommended)
- [ ] Chebyshev
- [ ] Uniform (baseline)

- [ ] Generate:


---

## 🔹 10. Convert Amplitude → Conductance

- [ ] Compute:


- [ ] Normalize:
- [ ] Total radiated power consistent

---

## 🔹 11. Map to Physical Slot Geometry

For each slot `n`:

- [ ] Solve:


- [ ] Assign:


---

## 🔹 12. Second-Order Lobe Control (CORE THESIS)

- [ ] Ensure:


- [ ] (Optional) Introduce aperiodic spacing:
- [ ] Slight variations in `d_n`

- [ ] Use truncated waveguide structure:
- [ ] Extract element pattern `F_element(θ)`

- [ ] Check:
- [ ] Does element suppress unwanted angles?

---

## 🔹 13. Analytical Pattern Prediction

- [ ] Compute array factor:


- [ ] Compute total pattern:


- [ ] Evaluate:
- [ ] Main beam
- [ ] Sidelobe level
- [ ] Second-order lobes

---

## 🔹 14. Full CST Array Build

- [ ] Build full geometry using:
- [ ] `{x_n, L_n, z_n}`

- [ ] Simulate full structure

---

## 🔹 15. Evaluate Performance

- [ ] Check:
- [ ] Radiation pattern
- [ ] Sidelobe level
- [ ] Second-order lobes
- [ ] Gain
- [ ] S11

---

## 🔹 16. Iterate / Optimise

- [ ] Adjust:
- [ ] Taper
- [ ] Offsets
- [ ] Spacing
- [ ] Waveguide truncation

- [ ] Re-run CST

---

## 🔹 17. Final Validation

- [ ] Compare:
- [ ] Standard slot array vs your design

- [ ] Demonstrate:
- [ ] Reduction in second-order lobes
- [ ] Improved pattern quality

---

## 🔹 ⚠️ Hard Rules (DO NOT BREAK)

- [ ] ALWAYS design at:


- [ ] NEVER use:


- [ ] DO NOT pick peak G blindly
- [ ] ALWAYS retune slot length per offset
- [ ] ALWAYS validate with full CST (coupling exists)

---

## 🔹 🧠 Final Mental Model

- CST gives:
→ slot behaviour

- You design:
→ how slots work together

- Goal:
→ control radiation → kill unwanted lobes

---