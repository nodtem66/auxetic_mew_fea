clc; clear; close all;

data = readtable("Scaffold_dimension\pore_area.xlsx");
design_group = categorical(data.design);
data.design = design_group;

%% Anova with turkey post-hoc
y = horzcat( ...
    data{data.design == 'h_cell', 'pore_area_mm2'}, ...
    data{data.design == 'sreg', 'pore_area_mm2'}, ...
    data{data.design == 'sinv', 'pore_area_mm2'}, ...
    data{data.design == 'stri', 'pore_area_mm2'} ...
    );

x = {'HCELL', 'SREG', 'SINV', 'STRI'};
print_anova(y, x);
% Result: F(3,16)=527.41, p=0.00
% HCELL - SREG / HCELL - STRI / SREG - SINV / SREG - STRI / SINV - STRI

%% Plot
% load colors
load("./Biaxial test/label_colors.mat");
colors = [label_colors.hcell; label_colors.sreg; label_colors.sinv; label_colors.stri];
% sort from min to max
figure; hold on;
y_size = size(y, 1);
for i = 1:4
b = boxchart(ones(y_size, 1).*i, y(:, i), 'BoxFaceColor', colors(i, :), 'MarkerStyle', '.', 'MarkerColor', 'black', 'BoxFaceAlpha', 0.5);
end
ylabel('Pore area [mm^2]');
xticks(1:4);
xticklabels(x);
ylim([0 1]);
%%
sigline([1 2], 0.85, 'TextPos', 0.83);
sigline([3 4], 0.89, 'TextPos', 0.87);
sigline([2 3], 0.89, 'TextPos', 0.87);
sigline([2 4], 0.93, 'TextPos', 0.91);
sigline([1 4], 0.97, 'TextPos', 0.95);