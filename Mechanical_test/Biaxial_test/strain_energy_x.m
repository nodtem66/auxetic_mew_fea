%% Anova with turkey post-hoc
clear; close all; clc;
addpath("../Draft/Scripts/");
data = readtable("all_x.csv");
data.group = categorical(data.dataset_label);
y = horzcat( ...
    data{data.group == 'hcell', 'strain_energy'}, ...
    data{data.group == 'sreg', 'strain_energy'}, ...
    data{data.group == 'sinv', 'strain_energy'}, ...
    data{data.group == 'stri', 'strain_energy'} ...
    );

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
vartestn(data.strain_energy, data.group);
% Result: non-equal variance
% use Welch ANOVA
%%
print_wanova(data.strain_energy, data.group);
% Result: No significant differences between fiber diameter
% F(3, 3.34)=7.614, p=0.054

%%
print_kruskal(data.strain_energy, data.group);
% Result: No significant
% Chi-sq(3,8)=7.051, p=0.070

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
ylabel('U [kJ/m^3]');
title('Strain energy (X axis)');
% sigline([1 2], 0.48, 'Text', '**');
% sigline([1 3], 0.5, 'Text', '**');
% sigline([1 4], 0.52, 'Text', '**');
fontsize(gca().XAxis, 10, 'points');