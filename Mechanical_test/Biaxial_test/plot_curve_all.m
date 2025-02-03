%% clear;
clc; close all; clear;

%% HCELL
h1 = load("hcell_1.mat");
h2 = load("hcell_2.mat");
h3 = load("hcell_3.mat");
h4 = load("hcell_4.mat");

dataset = {h1, h2, h3, h4};
figure;
hold on;
interp_and_plot(dataset, [63, 125, 178]./255, '-');


% SINV correct
sinvc1 = load("sinv_correct_1.mat");
sinvc2 = load("sinv_correct_2.mat");
sinvc3 = load("sinv_correct_3.mat");

dataset = {sinvc1, sinvc2, sinvc3};
interp_and_plot(dataset, [145, 58, 227]./255, '-');

% sreg correct
sregc1 = load("sreg_correct_1.mat");
sregc2 = load("sreg_correct_2.mat");
sregc3 = load("sreg_correct_3.mat");

dataset = {sregc1, sregc2, sregc3};
interp_and_plot(dataset, [68, 182, 118]./255, '-');

% stri correct
stric1 = load("stri_correct_001.mat");
stric2 = load("stri_correct_002.mat");
stric3 = load("stri_correct_003.mat");

dataset = {stric1, stric2, stric3};
interp_and_plot(dataset, [255, 77, 12]./255, '-');

%% Labels
title('Biaxial tensile testing (X axis)');
xlabel('Engineering strain [-]');
ylabel('Engineering stress [MPa]');
legend('HCELL', 'SINV', 'SREG', 'STRI');
ylim([-0.02 0.9]);

fontsize(gca().Legend, 10, "points");

%% Functions
function interp_and_plot(dataset, color, linestyle)
xdata = @(d) (d.XStrain);
ydata = @(d) (smooth(d.XStress_kPa));
xq = linspace(0, 2.5, 400);
yq = zeros(length(dataset), length(xq));
for i = 1:length(dataset)
    d = dataset{i};
    yq(i, :) = interp1(xdata(d), ydata(d), xq, "pchip");
    %plot(xq, yq(i, :), '.-');
end
%plot(xq, yq)
confplot(xq, yq/1000, color, 'LineStyle', linestyle, 'Smooth', 20, 'Lower', 0);
end