%% Anova with turkey post-hoc
clear; close all; clc;
addpath("../Draft/Scripts/");
data = readtable("all_y.csv");
data.group = categorical(data.dataset_label);
y = horzcat( ...
    data{data.group == 'hcell', 'stiffness_kPa'}, ...
    data{data.group == 'sreg', 'stiffness_kPa'}, ...
    data{data.group == 'sinv', 'stiffness_kPa'}, ...
    data{data.group == 'stri', 'stiffness_kPa'} ...
    );

y = y ./ 1000; % [kPa] -> [MPa]
x = {'HCELL', 'SREG', 'SINV', 'STRI'};
print_anova(y, x);
% Result: No significant differences between fiber diameter

%% Plot
% load colors
load("label_colors.mat");
% sort from min to max
figure;
colors = [label_colors.sreg; label_colors.hcell; label_colors.sinv; label_colors.stri];
boxchart(repmat(1, 3, 1), y(:, 2), 'BoxFaceColor', label_colors.sreg, 'MarkerStyle', '.', 'MarkerColor', 'black', 'BoxFaceAlpha', 0.5);
hold on;
boxchart(repmat(2, 3, 1), y(:, 1), 'BoxFaceColor', label_colors.hcell, 'MarkerStyle', '.', 'MarkerColor', 'black', 'BoxFaceAlpha', 0.5);
boxchart(repmat(3, 3, 1), y(:, 3), 'BoxFaceColor', label_colors.sinv, 'MarkerStyle', '.', 'MarkerColor', 'black', 'BoxFaceAlpha', 0.5);
b = boxchart(repmat(4, 3, 1), y(:, 4), 'BoxFaceColor', label_colors.stri, 'MarkerStyle', '.', 'MarkerColor', 'black', 'BoxFaceAlpha', 0.5);
b.Parent.XTick = [1 2 3 4];
b.Parent.XTickLabel = x([2 1 3 4]);
b.Parent.YTick = 0.2:0.1:1;

%% Annotations
ylabel('Stiffness [MPa]');
title('Stiffness (Y axis)');
sigline([1 2], 0.7);
sigline([1 3], 0.85, 'Text', '**');
sigline([1 4], 0.91, 'Text', '**');
fontsize(gca().XAxis, 10, 'points')