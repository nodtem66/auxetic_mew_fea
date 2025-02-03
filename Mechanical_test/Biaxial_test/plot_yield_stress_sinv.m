%% Anova with turkey post-hoc
clear; close all; clc;
addpath("../Draft/Scripts/");
data = readtable("all_x.csv");
data = [data; readtable("all_x_offset.csv")];
data.group = categorical(data.dataset_label);
data(21, :) = [];
%%
y = horzcat( ...
    data{data.group == 'sinv', 'yield_stress_kPa'}, ...
    data{data.group == 'sinv_offset', 'yield_stress_kPa'});
y = y ./ 1000; % [kPa] -> [MPa];
x = {'SINV', 'SINV-offset'};
print_anova(y, x);
% Result: No significant differences between fiber diameter

%% Plot
% load colors
load("label_colors.mat");
normal_color = label_colors.sinv;
offset_color = rgb2hsv(normal_color);
offset_color(3) = offset_color(3) * 0.35;
offset_color = hsv2rgb(offset_color);
figure;
boxchart(repmat(1, 3, 1), y(:, 1), 'BoxFaceColor', normal_color, 'MarkerStyle', '.', 'MarkerColor', 'black', 'BoxFaceAlpha', 0.5);
hold on;
b = boxchart(repmat(2, 3, 1), y(:, 2), 'BoxFaceColor', offset_color, 'MarkerStyle', '.', 'MarkerColor', 'black', 'BoxFaceAlpha', 0.5);
b.Parent.XTick = [1 2];
b.Parent.XTickLabel = x;
ylim([0 0.8]);
yticks(0:0.1:0.8);

ylabel('Yield stress [MPa]');
sigline([1 2], 0.525, 'Text', 'ns', 'TextPos',0.525);
%% Annotations
fontsize(gca().XAxis, 12, 'points')