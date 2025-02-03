%% Anova with turkey post-hoc
clear; close all; clc;
addpath("../Draft/Scripts/");
data = readtable("all_x.csv");
data = [data; readtable("all_x_offset.csv")];
data.group = categorical(data.dataset_label);
data(21, :) = [];
%%
y = horzcat( ...
    data{data.group == 'sinv', 'strain_energy'}, ...
    data{data.group == 'sinv_offset', 'strain_energy'});

x = {'SREG', 'SREG-offset'};
print_anova(y, x);
% Result: No significant differences between fiber diameter

%% Plot
load("label_colors.mat");
normal_color = label_colors.sinv;
offset_color = rgb2hsv(normal_color);
offset_color(3) = offset_color(3) * 0.35;
offset_color = hsv2rgb(offset_color);
figure;
y = y ./ 1000;
boxchart(repmat(1, 3, 1), y(:, 1), 'BoxFaceColor', normal_color, 'MarkerStyle', '.', 'MarkerColor', 'black', 'BoxFaceAlpha', 0.5);
hold on;
b = boxchart(repmat(2, 3, 1), y(:, 2), 'BoxFaceColor', offset_color, 'MarkerStyle', '.', 'MarkerColor', 'black', 'BoxFaceAlpha', 0.5);
b.Parent.XTick = [1 2];
b.Parent.XTickLabel = x;
ylim([0 0.6]);
b.Parent.YTick = 0:0.1:0.6;
ylabel('U [MJ/m^3]');
sigline([1 2], 0.245, 'Text', 'ns', 'TextPos', 0.245);

%% Annotations
fontsize(gca().XAxis, 12, 'points')