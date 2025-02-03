%% Anova with turkey post-hoc
clear; close all; clc;
addpath("../Draft/Scripts/");
data = readtable("all_x.csv");
data.group = categorical(data.dataset_label);
y = horzcat( ...
    data{data.group == 'hcell', 'yield_stress_kPa'}, ...
    data{data.group == 'sreg', 'yield_stress_kPa'}, ...
    data{data.group == 'sinv', 'yield_stress_kPa'}, ...
    data{data.group == 'stri', 'yield_stress_kPa'} ...
    );
y = y ./ 1000; % [kPa] -> [MPa]
x = {'HCELL', 'SREG', 'SINV', 'STRI'};

%% Normality test
normalitytest(y(:,1));
% Result: normal
normalitytest(y(:,2));
% Result: normal
normalitytest(y(:,3));
% Result: normal
normalitytest(y(:,4));
% Result: normal

%% Variance test
vartestn(data.yield_stress_kPa, data.group);
% Result: non-equal variance
% use Welch ANOVA
%% 
print_wanova(data.yield_stress_kPa, data.group);
% Result: F(3, 4.04)=152.505, p=0.000

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
ylabel('Yield stress [MPa]');
title('Yield stress (X axis)');
sigline([1 2], 0.48, 'Text', '**');
sigline([1 3], 0.5, 'Text', '**');
sigline([1 4], 0.52, 'Text', '**');
fontsize(gca().XAxis, 10, 'points');