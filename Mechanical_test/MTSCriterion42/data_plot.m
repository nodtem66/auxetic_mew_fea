clc; clear; close all;

%% Load data (TSV format)
% Columns: Crosshead [mm], Load [N], Time [s]
sample = {
    readtable("Test Run 8 12-15-23 16 43 32 PM\DAQ- Crosshead, … - (Timed).txt")
    readtable("Test Run 11 12-15-23 17 10 05 PM\DAQ- Crosshead, … - (Timed).txt")
    readtable("Test Run 13 12-15-23 17 11 28 PM\DAQ- Crosshead, … - (Timed).txt")
    readtable("Test Run 14 12-15-23 17 23 09 PM\DAQ- Crosshead, … - (Timed).txt")
    readtable("Test Run 15 12-15-23 17 35 06 PM\DAQ- Crosshead, … - (Timed).txt")
};
modulus = zeros(5, 1);
yield_stress = zeros(5,1);
yield_strain = zeros(5,1);
%% Calculations
gauge_length = 9.73; % [mm] L0 
thickness = [3.667 3.983 3.730 3.850 3.683]; % [mm]
width = [3.167 3.250 3.316 3.350 3.450]; % [mm]
final_width = [1.500 1.450 1.416 1.600 1.733]; % [mm]
cross_area = width .* thickness;
laterial_strain = (final_width - width)./width;
axial_strain = (80-28)/9.73;
poisson = -laterial_strain./axial_strain;


%% Sample cleaning (removing artifact at 0.3N)
strain_data = {};
stress_data = {};

% sample 1-3
for i = [1 2 3]
% Remove 9 - 19 due to preload artifacts
strain = (sample{i}.Crosshead - sample{i}.Crosshead(1))./gauge_length; % [mm/mm]
stress = sample{i}.Load ./ cross_area(i); % [N/mm2 = MPa]

preload_index = 8:20;
strain_1 = strain(1:preload_index(1));
strain_2 = strain(preload_index(end)+1:end) - strain(preload_index(end)) + strain(preload_index(1));
strain = vertcat(strain_1, strain_2);
stress = vertcat(stress(1:preload_index(1)), stress(preload_index(end)+1:end));
figure;
plot(strain(1:1200), stress(1:1200));
title(i);
strain_data{i} = strain;
stress_data{i} = stress;
end

% sample 4 cleaning
i = 4;
% 1-18 and 23 - 36
strain = (sample{i}.Crosshead - sample{i}.Crosshead(19))./gauge_length; % [mm/mm]
stress = sample{i}.Load ./ cross_area(i); % [N/mm2 = MPa]
strain1 = strain(19:22);
strain2 = strain(37:end) - strain(36) + strain(23);
strain = vertcat(strain1, strain2);
stress = vertcat(stress(19:22), stress(37:end));
figure;
plot(strain, stress);
title(i);
strain_data{i} = strain;
stress_data{i} = stress;

% sample 5 cleaning
i = 5;
% 5-22 and 28-40
strain = (sample{i}.Crosshead - sample{i}.Crosshead(1))./gauge_length; % [mm/mm]
stress = sample{i}.Load ./ cross_area(i); % [N/mm2 = MPa]
strain1 = strain(1:4);
strain2 = strain(23:27) - strain(22) + strain(4);
strain3 = strain(41:end) - strain(40) + strain2(end);
strain = vertcat(strain1, strain2, strain3);
stress = vertcat(stress(1:4), stress(23:27), stress(41:end));
figure;
plot(strain, stress);
title(i);
strain_data{i} = strain;
stress_data{i} = stress;

%% Plot presentative curve
[peak_stress, loc, ~, ~] = findpeaks(stress, strain, 'MinPeakProminence', 1, 'NPeaks', 1);
last_index = find(strain <= loc, 1, 'last');
first_index = 1;
max_y = max(stress);
strain = strain - strain(first_index);
for j = 0:(last_index-first_index-1)
    y = stress(first_index:last_index-j);
    y = y - y(1);
    x = strain(first_index:last_index-j);
    model = fitlm(x, y, 'linear', 'Intercept', false);
    fprintf("R2: %.3f Slope: %.3f\n", model.Rsquared.Ordinary, model.Coefficients.Estimate(1));
    if model.Rsquared.Ordinary >= 0.99
        break
    end
end

% Plot curve
plot(strain(first_index:400), stress(first_index:400), 'k-', 'HandleVisibility', 'off');
hold on;

% Plot yield point
yield_index = last_index - j;
plot(strain(yield_index), stress(yield_index), 'r*');

% Plot peak stress
[uts_stress, uts_index] = max(stress(first_index:last_index+10));
plot(strain(first_index+uts_index-1), uts_stress+0.15, 'rv');

% Plot slope
offset = stress(first_index);
xx = (uts_stress - offset) / model.Coefficients.Estimate(1);
plot([0 xx], [offset uts_stress], 'r--');

% Area of Strain energy density
g = area(strain(1:yield_index), stress(1:yield_index), 'FaceColor','#000', 'FaceAlpha', 0.1, 'EdgeColor', 'none', 'LineStyle', 'none');
g.BaseLine.Color = 'none';

xlabel('Engineering strain, \epsilon [mm/mm]');
ylabel('Engineering stress, \sigma [MPa]');
title('Mechanical properties');
legend('Yield', 'UTS', 'Stiffness', 'Strain energy densisty', 'Location', 'southeast');
ylim([2 max_y+0.5]);

%% Plot all curve with error bar
xq = linspace(0, 1, 300);
yq = zeros(length(stress_data), length(xq));
for i = 1:length(stress_data)
    d = stress_data{i};
    yq(i, :) = interp1(strain_data{i}, stress_data{i}, xq, "pchip");
end
confplot(xq, yq, 'k', 'Lower', 0);
title('Uniaxial tensile test of Bulk PCL');
xlabel('Engineering strain, \epsilon [mm/mm]');
ylabel('Engineering stress, \sigma [MPa]');

%% Find yield, UTS, strain energy density, and stiffness
N_data = length(strain_data);
yield_strain = zeros(N_data, 1); 
yield_stress = zeros(N_data, 1); % [MPa]
uts_stress = zeros(N_data, 1); % [MPa]
uts_strain = zeros(N_data, 1);
strain_energy = zeros(N_data, 1); % [MJ/m3]
stiffness_MPa = zeros(N_data, 1); % [MPa]
for i = 1:N_data
    strain = strain_data{i}; % [mm/mm]
    stress = stress_data{i}; % [MPa]
    [peak_stress, loc, ~, ~] = findpeaks(stress, strain, 'MinPeakProminence', 1, 'NPeaks', 1);
    last_index = find(strain <= loc, 1, 'last');
    first_index = 1;
    uts_stress(i) = peak_stress;
    uts_strain(i) = loc;
    for j = 0:(last_index-first_index-1)
        y = stress(first_index:last_index-j);
        y = y - y(1);
        x = strain(first_index:last_index-j);
        model = fitlm(x, y, 'linear', 'Intercept', false);
        %fprintf("R2: %.3f Slope: %.3f\n", model.Rsquared.Ordinary, model.Coefficients.Estimate(1));
        if model.Rsquared.Ordinary >= 0.99
            break
        end
    end
    if j == last_index-first_index-1
        error("Not found linear part with R2 >= 0.99");
    end
    yield_strain(i) = strain(last_index-j);
    yield_stress(i) = stress(last_index-j);
    stiffness_MPa(i) = model.Coefficients.Estimate(1);
    strain_energy(i) = trapz(strain(1:last_index-j), stress(1:last_index-j));
end

mech_table = table(stiffness_MPa, yield_stress, yield_strain, uts_stress, uts_strain, strain_energy);

%% Export strain-stress data to csv
for i = 1:5
    t = table(strain_data{i}, stress_data{i}, 'VariableNames', ["strain", "stress_MPa"]);
    writetable(t, "sample" + i + ".csv");
end