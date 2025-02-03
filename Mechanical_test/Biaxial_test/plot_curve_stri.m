%% clear;
clc; close all; clear;
addpath("../Draft/Scripts/");

%% SINV correct
load("label_colors.mat");
normal_color = label_colors.stri;
offset_color = rgb2hsv(normal_color);
offset_color(3) = offset_color(3) * 0.35;
offset_color = hsv2rgb(offset_color);
figure;
hold on;

correct1 = load("stri_correct_002.mat");
correct2 = load("stri_correct_003.mat");
correct3 = load("stri_correct_001.mat");

dataset = {correct1, correct2, correct3};
interp_and_plot(dataset, normal_color, '-');

offset1 = load("stri_003.mat");
offset2 = load("stri_001.mat");
offset3 = load("stri_002.mat");
offset4 = load("stri_004.mat");

dataset = {offset1, offset2, offset3, offset4};
interp_and_plot(dataset, offset_color, ':');

xlabel('Engineering strain [-]');
ylabel('Engineering stress [MPa]');
legend('STRI', 'STRI-offset', 'Location', 'southeast');
ylim([-0.02 0.9]);
xticks(0:0.5:2);
%%
fontsize(gca().Legend, 10, "points");
%xline(0.05, '--' ,'5%', 'Color', '#333', 'HandleVisibility', 'off');

%% Functions
function interp_and_plot(dataset, color, linestyle)
xdata = @(d) (d.XStrain);
ydata = @(d) (smooth(d.XStress_kPa));
xq = linspace(0, 2, 200);
yq = zeros(length(dataset), length(xq));
for i = 1:length(dataset)
    d = dataset{i};
    yq(i, :) = interp1(xdata(d), ydata(d), xq, "pchip");
    %plot(xdata(d), ydata(d)/1000, 'Color', 'k', 'LineStyle', linestyle);
end
%plot(xq, yq)
confplot(xq, yq/1000, color, 'LineStyle', linestyle, 'Smooth', 20, 'Lower', 0);
end