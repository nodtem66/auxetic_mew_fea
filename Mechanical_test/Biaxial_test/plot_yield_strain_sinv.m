%% Anova with turkey post-hoc
clear; close all; clc;
addpath("../Draft/Scripts/");
data = readtable("all_x.csv");
data = [data; readtable("all_x_offset.csv")];
data.group = categorical(data.dataset_label);
data(21, :) = [];
%%
y = horzcat( ...
    data{data.group == 'sinv', 'yield_strain'}, ...
    data{data.group == 'sinv_offset', 'yield_strain'});

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
ylim([0 1.6]);
yticks(0:0.2:1.6);
ylabel('Yield strain [mm/mm]');
sigline([1 2], 1.1, 'Text', 'ns', 'TextPos', 1.1);
%% Annotations
fontsize(gca().XAxis, 12, 'points');