clc; clear; close all;

data = readtable("Scaffold_dimension\pore_area.xlsx");
design_group = categorical(data.design);
data.design = design_group;

%% Basic stats
data_stats = grpstats(data, "design", ["mean", "std"], "DataVars", ["min_feret_mm", "max_feret_mm"]);

%% Anova with turkey post-hoc
y = horzcat( ...
    data{data.design == 'h_cell', 'min_feret_mm'}, ...
    data{data.design == 'sreg', 'min_feret_mm'}, ...
    data{data.design == 'sinv', 'min_feret_mm'}, ...
    data{data.design == 'stri', 'min_feret_mm'} ...
    );

x = {'HCELL', 'SREG', 'SINV', 'STRI'};
print_anova(y, x);
% Result: F(3,16)=613.89, p=0.00
 % Group A     Group B     Lower Limit      A-B      Upper Limit     P-value  
 %    _________    ________    ___________    _______    ___________    __________
 % 
 %    {'HCELL'}    {'SREG'}       -0.6977     -0.6452      -0.5927      4.9638e-19
 %    {'HCELL'}    {'SINV'}    -0.0071042      0.0454     0.097904         0.10277
 %    {'HCELL'}    {'STRI'}       -0.3773     -0.3248      -0.2723      2.9668e-11
 %    {'SREG' }    {'SINV'}        0.6381      0.6906       0.7431      1.9954e-20
 %    {'SREG' }    {'STRI'}        0.2679      0.3204       0.3729      3.7172e-11
 %    {'SINV' }    {'STRI'}       -0.4227     -0.3702      -0.3177      3.0252e-12

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
ylabel('Pore size [mm]');
ylim([0 1.4]);
yticks(0:0.2:1.4);
xticks(1:4);
xticklabels(x);
%%
sigline([1 2], 1.2, 'TextPos', 1.16);
sigline([3 4], 1.24, 'TextPos', 1.2);
sigline([2 3], 1.24, 'TextPos', 1.2);
sigline([2 4], 1.28, 'TextPos', 1.24);
sigline([1 4], 1.32, 'TextPos', 1.28);