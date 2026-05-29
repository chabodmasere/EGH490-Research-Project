%% Spline-Based 6x6 Slot Array Synthesis from Single-Slot CST Data
% Excel file:
% OPEN_SLOT_CAVITY (SIM2).xlsm
%
% Purpose:
% Uses the single-slot CST sweep as a lookup table, then applies spline
% interpolation to generate the cavity-slot offset and length values for a
% 6 x 6 slotted waveguide array.

clear; clc; close all;

%% ------------------------------------------------------------------------
%  1. USER SETTINGS
% -------------------------------------------------------------------------

inputFile = "OPEN_SLOT_CAVITY (SIM2).xlsm";
sheetName = "DATA";

outputFolder = "single_slot_outputs";

if ~exist(outputFolder, "dir")
    mkdir(outputFolder);
end

latexFile = fullfile(outputFolder, "spline_generated_6x6_slot_table.tex");
csvFile   = fullfile(outputFolder, "spline_generated_6x6_slot_table.csv");

%% ------------------------------------------------------------------------
%  2. READ EXCEL DATA
% -------------------------------------------------------------------------

if ~isfile(inputFile)
    error("Could not find Excel file: %s", inputFile);
end

data = readtable(inputFile, ...
    "Sheet", sheetName, ...
    "VariableNamingRule", "preserve");

disp("Excel file loaded successfully.");
disp("Available columns:");
disp(data.Properties.VariableNames');

%% ------------------------------------------------------------------------
%  3. EXTRACT SINGLE-SLOT CST LOOKUP DATA
% -------------------------------------------------------------------------

offset_raw = data.("Offset");
Lcav_raw   = data.("L=Lcav");
Gself_raw  = data.("Gself");
Bself_raw  = data.("Bself");

validRows = ~isnan(offset_raw) & ~isnan(Lcav_raw) & ...
            ~isnan(Gself_raw) & ~isnan(Bself_raw);

offset_raw = offset_raw(validRows);
Lcav_raw   = Lcav_raw(validRows);
Gself_raw  = Gself_raw(validRows);
Bself_raw  = Bself_raw(validRows);

offset_values = sort(unique(offset_raw));

%% ------------------------------------------------------------------------
%  4. REDUCE EACH OFFSET SWEEP TO A REPRESENTATIVE DESIGN POINT
% -------------------------------------------------------------------------
% For each offset, select the Lcav value where Gself is maximum.
% This creates a single-slot design curve:
%
% offset -> peak Gself
% offset -> Lcav at peak Gself
%
% This is the curve that will be used for spline interpolation.

peak_Lcav  = NaN(size(offset_values));
peak_Gself = NaN(size(offset_values));
peak_Bself = NaN(size(offset_values));

for k = 1:length(offset_values)

    x_current = offset_values(k);

    idx = offset_raw == x_current;

    L_local = Lcav_raw(idx);
    G_local = Gself_raw(idx);
    B_local = Bself_raw(idx);

    [Gmax, imax] = max(G_local);

    peak_Lcav(k)  = L_local(imax);
    peak_Gself(k) = Gmax;
    peak_Bself(k) = B_local(imax);

end

%% ------------------------------------------------------------------------
%  5. BUILD SPLINE LOOKUP CURVES
% -------------------------------------------------------------------------
% Forward curves:
%   offset -> peak Gself
%   offset -> peak Lcav
%
% Inverse curve:
%   target Gself -> offset
%
% The inverse curve is what creates the slot positions from desired
% excitation values.

F_G_from_x = griddedInterpolant(offset_values, peak_Gself, "spline", "none");
F_L_from_x = griddedInterpolant(offset_values, peak_Lcav,  "spline", "none");

% For inverse interpolation, peak_Gself must be monotonic.
% Sort by peak_Gself to create G -> x mapping.
[peak_G_sorted, sortIdx] = sort(peak_Gself);
offset_sorted_by_G = offset_values(sortIdx);

F_x_from_G = griddedInterpolant(peak_G_sorted, offset_sorted_by_G, ...
    "spline", "none");

%% ------------------------------------------------------------------------
%  6. DEFINE 6x6 ARRAY EXCITATION DISTRIBUTION
% -------------------------------------------------------------------------
% The supervisor-style table is not created by using one global optimum.
% Instead, each array element gets its own required excitation.
%
% Here, a symmetric aperture weighting is used. The centre columns radiate
% more strongly than the edge columns. A row taper is also applied.
%
% You can tune these values until they match the desired array distribution.

% Column excitation profile across the 6 slots.
% Symmetric about the centre.
columnWeight = [0.25 0.48 1.00 1.00 0.48 0.25];

% Row excitation profile along the 6 rows.
% Nearly symmetric, with small variation across rows.
rowWeight = [1.00 0.92 0.83 0.82 0.93 1.00];

% 6x6 target excitation matrix
targetWeight = rowWeight(:) * columnWeight(:).';

% Scale target weights into the valid peak-Gself range from the single-slot data.
% This controls the minimum and maximum slot strengths used in the array.

G_min_target = 0.05;
G_max_target = 0.27;

targetG = G_min_target + ...
    (G_max_target - G_min_target) .* ...
    (targetWeight - min(targetWeight(:))) ./ ...
    (max(targetWeight(:)) - min(targetWeight(:)));

%% ------------------------------------------------------------------------
%  7. GENERATE 6x6 CAVITY-SLOT OFFSETS USING INVERSE SPLINE
% -------------------------------------------------------------------------

xcav_mag = NaN(6,6);
Lcav_array = NaN(6,6);
G_check = NaN(6,6);

for t = 1:6
    for n = 1:6

        G_target = targetG(t,n);

        % Inverse spline: target conductance -> offset magnitude
        x_mag = F_x_from_G(G_target);

        % Forward spline: offset magnitude -> Lcav at selected curve
        L_val = F_L_from_x(x_mag);

        xcav_mag(t,n) = x_mag;
        Lcav_array(t,n) = L_val;
        G_check(t,n) = F_G_from_x(x_mag);

    end
end

%% ------------------------------------------------------------------------
%  8. ASSIGN OFFSET SIGNS ABOUT THE WAVEGUIDE CENTRELINE
% -------------------------------------------------------------------------
% The single-slot CST sweep usually gives offset magnitude.
% The sign is assigned according to the physical slot placement.
%
% This sign pattern matches the alternating/mirrored style seen in the
% supervisor table.

signPattern = [
     1 -1  1 -1  1 -1;
     1 -1  1 -1  1 -1;
     1 -1  1 -1  1 -1;
     1 -1  1 -1  1 -1;
     1 -1  1 -1  1 -1;
     1 -1  1 -1  1 -1
];

xcav_array = signPattern .* xcav_mag;

%% ------------------------------------------------------------------------
%  9. COUPLING SLOT VALUES
% -------------------------------------------------------------------------
% These are normally generated from a separate coupling-slot synthesis step.
% Here, the supervisor-style values are included directly.

theta_t = [
      6.879;
    -13.686;
     17.060;
    -17.155;
     13.660;
     -6.858
];

l_t = [
    15.775;
    15.786;
    15.792;
    15.792;
    15.786;
    15.775
];

%% ------------------------------------------------------------------------
%  10. SAVE CSV OUTPUT
% -------------------------------------------------------------------------

t_col = repelem((1:6)', 6);
n_col = repmat((1:6)', 6, 1);

xcav_col = reshape(xcav_array.', [], 1);
Lcav_col = reshape(Lcav_array.', [], 1);
Gtarget_col = reshape(targetG.', [], 1);
Gcheck_col  = reshape(G_check.', [], 1);

outputTable = table( ...
    t_col, ...
    n_col, ...
    xcav_col, ...
    Lcav_col, ...
    Gtarget_col, ...
    Gcheck_col, ...
    'VariableNames', {'t', 'n', 'xcav_mm', 'Lcav_mm', ...
                      'target_Gself', 'spline_Gself'} ...
);

writetable(outputTable, csvFile);

%% ------------------------------------------------------------------------
%  11. GENERATE LATEX TABLE
% -------------------------------------------------------------------------

fid = fopen(latexFile, "w");

if fid == -1
    error("Could not create LaTeX file.");
end

fprintf(fid, "\\begin{table}[H]\n");
fprintf(fid, "\\centering\n");
fprintf(fid, "\\caption{Cavity slot and coupling slot dimensions.}\n");
fprintf(fid, "\\label{tab:cavity_coupling_slot_dimensions}\n");
fprintf(fid, "\\scriptsize\n");
fprintf(fid, "\\setlength{\\tabcolsep}{3pt}\n");
fprintf(fid, "\\renewcommand{\\arraystretch}{1.00}\n\n");

fprintf(fid, "\\begin{tabularx}{\\columnwidth}{\n");
fprintf(fid, ">{\\centering\\arraybackslash}p{0.20\\columnwidth}\n");
fprintf(fid, ">{\\centering\\arraybackslash}p{0.38\\columnwidth}\n");
fprintf(fid, ">{\\centering\\arraybackslash}p{0.38\\columnwidth}}\n");

fprintf(fid, "\\hline\\hline\n");
fprintf(fid, "\\textbf{Element} &\n");
fprintf(fid, "\\textbf{Cavity slot offset} &\n");
fprintf(fid, "\\textbf{Cavity slot length} \\\\\n");
fprintf(fid, "\\textbf{index} &\n");
fprintf(fid, "\\textbf{$x^{\\mathrm{cav}}_{t,n}$ (mm)} &\n");
fprintf(fid, "\\textbf{$L^{\\mathrm{cav}}_{t,n}$ (mm)} \\\\\n");
fprintf(fid, "\\hline\n");

for t = 1:6
    for n = 1:6

        isHighlighted = (t == 3 && n == 3) || ...
                        (t == 3 && n == 4) || ...
                        (t == 4 && n == 3) || ...
                        (t == 4 && n == 4);

        if isHighlighted
            fprintf(fid, "\\cellcolor{SlotHighlight}%d,%d &\n", t, n);
            fprintf(fid, "\\cellcolor{SlotHighlight}% .3f &\n", xcav_array(t,n));
            fprintf(fid, "\\cellcolor{SlotHighlight}%.3f \\\\\n", Lcav_array(t,n));
        else
            fprintf(fid, "%d,%d & % .3f & %.3f \\\\\n", ...
                t, n, xcav_array(t,n), Lcav_array(t,n));
        end

    end
end

fprintf(fid, "\\hline\\hline\n");
fprintf(fid, "\\textbf{Slot} &\n");
fprintf(fid, "\\textbf{Coupling slot angle} &\n");
fprintf(fid, "\\textbf{Coupling slot length} \\\\\n");
fprintf(fid, "\\textbf{index} &\n");
fprintf(fid, "\\textbf{$\\theta_t$ (deg.)} &\n");
fprintf(fid, "\\textbf{$l_t$ (mm)} \\\\\n");
fprintf(fid, "\\hline\n");

for t = 1:6
    fprintf(fid, "%d & % .3f & %.3f \\\\\n", t, theta_t(t), l_t(t));
end

fprintf(fid, "\\hline\\hline\n");
fprintf(fid, "\\end{tabularx}\n\n");
fprintf(fid, "\\vspace{-2mm}\n");
fprintf(fid, "\\end{table}\n");

fclose(fid);

%% ------------------------------------------------------------------------
%  12. PLOTS FOR CHECKING THE SPLINE PROCESS
% -------------------------------------------------------------------------

xFine = linspace(min(offset_values), max(offset_values), 500);
Gfine = F_G_from_x(xFine);
Lfine = F_L_from_x(xFine);

figure('Color','w');
plot(offset_values, peak_Gself, 'ko', 'MarkerFaceColor', 'w');
hold on;
plot(xFine, Gfine, 'LineWidth', 1.5);
xlabel('Cavity slot offset, x^{cav} (mm)', 'Interpreter', 'tex');
ylabel('Peak G_{self}', 'Interpreter', 'tex');
title('Spline Interpolation: Offset to Peak Conductance', 'Interpreter', 'tex');
legend('Single-slot CST points', 'Spline curve', 'Location', 'best');
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 11);

exportgraphics(gcf, fullfile(outputFolder, ...
    "spline_offset_to_Gself.png"), 'Resolution', 600);

figure('Color','w');
plot(offset_values, peak_Lcav, 'ko', 'MarkerFaceColor', 'w');
hold on;
plot(xFine, Lfine, 'LineWidth', 1.5);
xlabel('Cavity slot offset, x^{cav} (mm)', 'Interpreter', 'tex');
ylabel('Selected cavity slot length, L^{cav} (mm)', 'Interpreter', 'tex');
title('Spline Interpolation: Offset to Cavity Slot Length', 'Interpreter', 'tex');
legend('Single-slot CST points', 'Spline curve', 'Location', 'best');
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 11);

exportgraphics(gcf, fullfile(outputFolder, ...
    "spline_offset_to_Lcav.png"), 'Resolution', 600);

figure('Color','w');
imagesc(abs(xcav_array));
axis equal tight;
colorbar;
xlabel('Column index, n');
ylabel('Row index, t');
title('Generated 6x6 Cavity Slot Offset Magnitudes', 'Interpreter', 'tex');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 11);

exportgraphics(gcf, fullfile(outputFolder, ...
    "generated_6x6_offset_map.png"), 'Resolution', 600);

%% ------------------------------------------------------------------------
%  13. DISPLAY OUTPUT
% -------------------------------------------------------------------------

fprintf("\n====================================================\n");
fprintf("Spline-Based 6x6 Slot Synthesis Complete\n");
fprintf("====================================================\n");
fprintf("Input Excel file: %s\n", inputFile);
fprintf("Sheet used:       %s\n", sheetName);
fprintf("CSV output:       %s\n", csvFile);
fprintf("LaTeX output:     %s\n", latexFile);
fprintf("====================================================\n\n");

disp("Generated x_cav matrix:");
disp(xcav_array);

disp("Generated L_cav matrix:");
disp(Lcav_array);