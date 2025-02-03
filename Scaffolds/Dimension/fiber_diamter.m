clc; clear; close all;

data = readtable("Scaffold_dimension\fiber_diameter.xlsx");
design_group = categorical(data.design);
data.design = design_group;

%% Anova with turkey post-hoc
y = horzcat( ...
    data{data.design == 'h_cell', 'fiber_diameter_um'}, ...
    data{data.design == 'sreg', 'fiber_diameter_um'}, ...
    data{data.design == 'sinv', 'fiber_diameter_um'}, ...
    data{data.design == 'stri', 'fiber_diameter_um'} ...
    );

x = {'HCELL', 'SREG', 'SINV', 'STRI'};
print_anova(y, x);
% Result: No significant differences between fiber diameter
% F(3,16)=0.29, p=0.83

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
xticks(1:4);
xticklabels(x);
ylim([0 18]);
yticks(0:3:18);
ylabel('Fiber diameter [\mum]');