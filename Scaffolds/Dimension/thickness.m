clc; clear; close all;

%%
data = readtable("Scaffold_dimension\thickness.xlsx");
design_group = categorical(data.design);
data.design = design_group;

%% Anova with turkey post-hoc
y = horzcat( ...
    data{data.design == 'h_cell', 'thickness_um'}, ...
    data{data.design == 'sreg', 'thickness_um'}, ...
    data{data.design == 'sinv', 'thickness_um'}, ...
    data{data.design == 'stri', 'thickness_um'} ...
    );

x = {'HCELL', 'SREG', 'SINV', 'STRI'};
print_anova(y, x);
% Result: No significant differences between fiber diameter

%% Plot
% sort from min to max
figure;
b = boxchart(y(:, [3 1 4 2]), 'BoxFaceColor', 'black', 'MarkerStyle', '.', 'MarkerColor', 'black', 'BoxFaceAlpha', 0.5);
b.Parent.XTickLabel = x([3 1 4 2]);
ylabel('Pore area [mm^2]');
%%
ylim([0.15 0.9]);
sigline([1 2], 0.3, 'Text', 'ns', 'TextPos', 0.33);
sigline([2 3], 0.4);
sigline([1 3], 0.45);
hold on;
plot([1 3], [0.85 0.85], 'LineWidth', 2, 'Color', 'k');
plot([2 2], [0.85 0.87], 'LineWidth', 1, 'Color', 'k');
plot([2 4], [0.87 0.87], 'LineWidth', 1, 'Color', 'k');
plot([4 4], [0.87 0.85], 'LineWidth', 1, 'Color', 'k');
text(3, 0.88, '*', 'Color', 'k', 'HorizontalAlignment', 'center');