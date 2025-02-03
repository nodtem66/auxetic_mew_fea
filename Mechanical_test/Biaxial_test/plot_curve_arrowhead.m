%% clear;
clc; close all; clear;

%% SINV correct
data = readtable("arrowhead\arrowhead_5x_uniaxial_001\arrowhead_5x_004Data.xlsx");

%%
plot(data.Strain, smooth(data.Stress_kPa_), 'k');

%% Labels (Run after applying export setting)
xlabel('Engineering strain [-]');
ylabel('Engineering stress [kPa]');
%ylim([0 600]);
xlim([0 7]);

%xline(0.05, '--' ,'5%', 'Color', '#333', 'HandleVisibility', 'off');
t