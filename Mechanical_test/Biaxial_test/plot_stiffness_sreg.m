%% Anova with turkey post-hoc
clear; close all; clc;
addpath("../Draft/Scripts/");
data = readtable("all_x.csv");
data = [data; readtable("all_x_offset.csv")];

data.group = categorical(data.dataset_label);
%%
y = horzcat( ...
    data{data.group == 'sreg', 'stiffness_kPa'}, ...
    data{data.group == 'sreg_offset', 'stiffness_kPa'});

y = y ./ 1000; % [kPa] -> [MPa]
x = {'SREG', 'SREG-offset'};
print_anova(y, x);
% Result: No significant differences between fiber diameter

%% Plot
% load colors
load("label_colors.mat");
normal_color = label_colors.sreg;
offset_color = rgb2hsv(normal_color);
offset_color(3) = offset_color(3) * 0.35;
offset_color = hsv2rgb(offset_color);
% sort from min to max
figure;
boxchart(repmat(1, 3, 1), y(:, 1), 'BoxFaceColor', normal_color, 'MarkerStyle', '.', 'MarkerColor', 'black', 'BoxFaceAlpha', 0.5);
hold on;
b = boxchart(repmat(2, 3, 1), y(:, 2), 'BoxFaceColor', offset_color, 'MarkerStyle', '.', 'MarkerColor', 'black', 'BoxFaceAlpha', 0.5);
b.Parent.XTick = [1 2];
b.Parent.XTickLabel = x;

ylim([0 1.8]);
yticks(0:0.2:1.8);
ylabel('Stiffness [MPa]');
sigline([1 2], 0.85, 'Text', '**');
%%
fontsize(gca().XAxis, 12, 'points');
fontsize(gca().Title, 12, 'points');