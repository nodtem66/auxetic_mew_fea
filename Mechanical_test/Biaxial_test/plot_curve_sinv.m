%% clear;
clc; close all; clear;

%% SINV correct
load("label_colors.mat");
normal_color = label_colors.sinv;
offset_color = rgb2hsv(normal_color);
offset_color(3) = offset_color(3) * 0.35;
offset_color = hsv2rgb(offset_color);
figure;
hold on;

sinvc1 = load("sinv_correct_1.mat");
sinvc2 = load("sinv_correct_2.mat");
sinvc3 = load("sinv_correct_3.mat");

dataset = {sinvc1, sinvc2, sinvc3};
interp_and_plot(dataset, normal_color, '-');

sinv1 = load("sinv_1.mat");
sinv2 = load("sinv_2.mat");
sinv3 = load("sinv_3.mat");
sinv4 = load("sinv_4.mat");
dataset = {sinv1, sinv2, sinv3, sinv4};
interp_and_plot(dataset, offset_color, ':');

%% Labels (Run after applying export setting)
xlabel('Engineering strain [-]');
ylabel('Engineering stress [MPa]');
legend('SINV', 'SINV-offset', 'Location', 'southeast');
ylim([-0.02 1]);
fontsize(gca().Legend, 10, "points");
xticks(0:0.5:2);
yticks(0:0.2:1);
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