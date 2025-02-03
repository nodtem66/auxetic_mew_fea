%% Calculate the theoretical value of pore size and pore area from design
% clear
clear; close all; clc;

%% Load experiment data
pore_area = readtable("Scaffold_dimension\pore_area.xlsx");
design_group = categorical(pore_area.design);
pore_area.design = design_group;
pore_area_stats = grpstats(pore_area, "design", ["mean", "std"], "DataVars", ["pore_area_mm2", "min_feret_mm"]);

fiber_diameter = readtable("Scaffold_dimension\fiber_diameter.xlsx");
design_group = categorical(fiber_diameter.design);
fiber_diameter.design = design_group;
fiber_diameter_stats = grpstats(fiber_diameter, "design", ["mean", "std"], "DataVars", ["fiber_diameter_um"]);

%% HCELL
% Position x and y in mm 
pos = [0.55 3.3; 1.1 3.3; 1.1 3.45; 0.95 3.45; 0.95 4; 1.1 4; ...
    1.1 4.15; 0.55 4.15; 0.55 4; 0.7 4; 0.7 3.45; 0.55 3.45; 0.55 3.3];
print_area_and_pore_size(pos, "h_cell", fiber_diameter_stats, pore_area_stats);
% [Pore Area] Actual: 0.238 Ideal: 0.257 (0.928)
% [Pore size] Actual: 0.484 Ideal: 0.523 (0.926)

%% SREGL
% Position x and y in mm 
pos = [0 3.6; 0.25 3.35; 0.5 3.6; 0.75 3.85; 1 3.6; 1.25 3.85; 1 4.1; ...
    0.75 4.35; 1 4.6; 0.75 4.85; 0.5 4.6; 0.25 4.35; 0 4.6; -0.25 4.35; ...
    0 4.1; 0.25 3.85; 0 3.6];
print_area_and_pore_size(pos, "sreg", fiber_diameter_stats, pore_area_stats);
% [Pore Area] Actual: 0.789 Ideal: 0.920 (0.858)
% [Pore size] Actual: 1.129 Ideal: 1.226 (0.921)

%% SINV
% Position x and y in mm 
pos = [0 3.6; 0.25 3.4125; 0.5 3.6; 0.3125 3.85; 0.5 4.1; 0.25 4.2875; ...
    0 4.1; 0.1875 3.85; 0 3.6];
print_area_and_pore_size(pos, "sinv", fiber_diameter_stats, pore_area_stats);
% [Pore Area] Actual: 0.199 Ideal: 0.215 (0.927)
% [Pore size] Actual: 0.438 Ideal: 0.460 (0.954)

%% STRI
% Position x and y in mm 
pos = [0 3.6; 0.25 3.4125; 0.5 3.6; 0.75 3.7875; 0.995 3.6; 1.032 3.91; ...
    0.745 4.033; 0.458 4.156; 0.495 4.466; 0.208 4.343; 0.245 4.033; ...
    0.282 3.723; 0 3.6];
print_area_and_pore_size(pos, "stri", fiber_diameter_stats, pore_area_stats);
% [Pore Area] Actual: 0.331 Ideal: 0.383 (0.866)
% [Pore size] Actual: 0.809 Ideal: 0.917 (0.882)

%% calculate min ferret diameter
pos = pos - pos(1, :);
poly = polyshape(pos(:, 1), pos(:, 2));
poly_fiber = polybuffer(pos, 'lines', 0.014,'JointType','miter');
poly_area_wo_fiber = subtract(poly, poly_fiber);

% find minimal feret diameter by rotating the shape and measuring width


%% local functions
function print_area_and_pore_size(pos, design_name, fiber_diameter_stats, pore_area_stats)

fprintf("[%s]\n", design_name);
poly = poly_inner_area(pos, fiber_diameter_stats{design_name, "mean_fiber_diameter_um"}/1000);

actual = pore_area_stats{design_name, "mean_pore_area_mm2"};
ideal = area(poly);

fprintf("[Pore Area] Actual: %.3f Ideal: %.3f (%.3f)\n", actual, ideal, actual/ideal);

actual = pore_area_stats{design_name, "mean_min_feret_mm"};
ideal = minFeretDiameter(poly);

fprintf("[Pore size] Actual: %.3f Ideal: %.3f (%.3f)\n", actual, ideal, actual/ideal);

end

function [poly] = poly_inner_area(pos, fiber_diameter, plot_offset)
arguments
    pos % polygon x,y position
    fiber_diameter = 0.010 % [mm]
    plot_offset = [0 0] % Offset to plot all pores in the same figure
end
% Create polyshape from vertices and offset by fiber diameter
pos = pos - pos(1, :);
poly = polyshape(pos(:, 1), pos(:, 2));
poly_fiber = polybuffer(pos, 'lines', fiber_diameter,'JointType','miter');

plot(translate(poly, plot_offset), 'FaceAlpha', 0.5);
hold on;
plot(translate(poly_fiber, plot_offset), 'LineStyle', '--', 'FaceColor', 'k', 'FaceAlpha', 0.3);

xlabel('X position [mm]');
ylabel('Y position [mm]');
axis equal;

poly = subtract(poly, poly_fiber);
end

function d=feretDiam(V,theta)
   p=V*[cos(theta);sin(theta)];
   d=max(p,[],1)-min(p,[],1);
end

function [minDiam] = minFeretDiameter(poly)
fun=@(theta) feretDiam(poly.Vertices,theta);
Theta=linspace(-pi,pi,1e4);

[~,i0]=min(fun(Theta));
[~,minDiam]=fminsearch(@(t)fun(t),Theta(i0));
end