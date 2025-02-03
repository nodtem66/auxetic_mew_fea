%% Anova with turkey post-hoc
clear; close all; clc;
addpath("../Draft/Scripts/");
data = readtable("all_y.csv");
data.group = categorical(data.dataset_label);
y = horzcat( ...
    data{data.group == 'hcell', 'yield_strain'}, ...
    data{data.group == 'sreg', 'yield_strain'}, ...
    data{data.group == 'sinv', 'yield_strain'}, ...
    data{data.group == 'stri', 'yield_strain'} ...
    );

x = {'HCELL', 'SREG', 'SINV', 'STRI'};
print_anova(y, x);
% Result: No significant differences between fiber diameter
%%
print_kruskal(data.yield_strain, data.group);
% Result: No significant
% Chi-sq(3,8)=3.951, p=0.267
%% Plot
% load colors
load("label_colors.mat");
% sort from min to max
figure;
colors = [label_colors.sreg; label_colors.hcell; label_colors.sinv; label_colors.stri];
boxchart(repmat(1, 3, 1), y(:, 2), 'BoxFaceColor', label_colors.sreg, 'MarkerStyle', '.', 'MarkerColor', 'black', 'BoxFaceAlpha', 0.5);
hold on;
%plot(repmat(1, 3, 1), y(:, 2), 'o', 'Color', label_colors.sreg);

boxchart(repmat(2, 3, 1), y(:, 1), 'BoxFaceColor', label_colors.hcell, 'MarkerStyle', '.', 'MarkerColor', 'black', 'BoxFaceAlpha', 0.5);
%plot(repmat(2, 3, 1), y(:, 1), 'o', 'Color', label_colors.hcell);

boxchart(repmat(3, 3, 1), y(:, 3), 'BoxFaceColor', label_colors.sinv, 'MarkerStyle', '.', 'MarkerColor', 'black', 'BoxFaceAlpha', 0.5);
%plot(repmat(3, 3, 1), y(:, 3), 'o', 'Color', label_colors.sinv);

b = boxchart(repmat(4, 3, 1), y(:, 4), 'BoxFaceColor', label_colors.stri, 'MarkerStyle', '.', 'MarkerColor', 'black', 'BoxFaceAlpha', 0.5);
%plot(repmat(4, 3, 1), y(:, 4), 'o', 'Color', label_colors.stri);

b.Parent.XTick = [1 2 3 4];
b.Parent.XTickLabel = x([2 1 3 4]);

%% Annotations
b.Parent.YTick = 0.4:0.2:1.4;
ylim([0.4 1.4]);
ylabel('Yield strain [mm/mm]');
title('Yield strain (Y axis)');
%sigline([1 2], 0.6);
%sigline([1 3], 0.83, 'Text', '**');
%sigline([1 4], 0.91, 'Text', '**');
fontsize(gca().XAxis, 10, 'points')