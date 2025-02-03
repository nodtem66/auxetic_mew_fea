%% Analyse the tensile data from *.mat in X direction
% Only the designs with layer correction will be used
% hcell
% sinv_correct
% stri_correct
% sreg_correct
clc; close all; clear;

%% Load data
sinv1 = load("sinv_1.mat");
sinv2 = load("sinv_2.mat");
sinv3 = load("sinv_3.mat");
sinv4 = load("sinv_4.mat");

sreg1 = load("sreg_1.mat");
sreg2 = load("sreg_2.mat");
sreg3 = load("sreg_3.mat");

stri1 = load("stri_001.mat");
stri2 = load("stri_002.mat");
stri3 = load("stri_003.mat");
stri4 = load("stri_004.mat");

%%
dataset = {sinv1, sinv3, sinv4,...
    sreg1, sreg2, sreg3,...
    stri1, stri2, stri3, stri4};

start_stress = [20, 20, 20, ...
    10, 10, 10, ...
    10, 10, 10, 10];

yield_strain = zeros(length(dataset), 1);
yield_stress_kPa = zeros(size(yield_strain));
stiffness_kPa = zeros(size(yield_strain));
strain_energy = zeros(size(yield_strain));

for i = 1:length(dataset)
    d = dataset{i};
    origin_stress = d.YStress_kPa;
    d.YStress_kPa = smooth(d.YStress_kPa, 20);
    first_index = find(d.YStress_kPa >= start_stress(i), 1, 'first');
    last_index = find(d.YStrain >= 2.3, 1, 'first');
    fit_result = find_best_lm(d.YStrain, d.YStress_kPa, first_index, last_index);
    figure;
    hold on;
    title(i);
    plot(d.YStrain, origin_stress, 'g.');
    plot(d.YStrain, d.YStress_kPa, 'k-');
    plot(d.YStrain(first_index), d.YStress_kPa(first_index), 'r*');
    plot(d.YStrain(fit_result.yield_index), d.YStress_kPa(fit_result.yield_index), 'b*');
    
    last_index = fit_result.yield_index;
    yield_strain(i) = d.YStrain(last_index);
    yield_stress_kPa(i) = origin_stress(last_index);
    stiffness_kPa(i) = fit_result.model.Coefficients.Estimate(1);
    strain_energy(i) = trapz(d.YStrain(first_index:last_index), d.YStress_kPa(first_index:last_index));
end

%% Init table
dataset_label = {'sinv_offset'; 'sinv_offset'; 'sinv_offset';...
    'sreg_offset'; 'sreg_offset'; 'sreg_offset'; ...
    'stri_offset'; 'stri_offset'; 'stri_offset'; 'stri_offset'};
dataset_label = categorical(dataset_label);
if exist("t", "var")
    t = [t; table(dataset_label, yield_stress_kPa, yield_strain, stiffness_kPa, strain_energy)];
else
    t = table(dataset_label, yield_stress_kPa, yield_strain, stiffness_kPa, strain_energy);
end

%% Save table
writetable(t, 'all_x_offset.csv');

%%
function result = find_best_lm(strain, stress, first_index, last_index)
    for j = 0:(last_index-first_index-1)
        y = stress(first_index:last_index-j);
        y = y - y(1);
        x = strain(first_index:last_index-j);
        x = x - x(1);
        model = fitlm(x, y, 'linear', 'Intercept', false);
        %fprintf("R2: %.3f Slope: %.3f\n", model.Rsquared.Ordinary, model.Coefficients.Estimate(1));
        if model.Rsquared.Ordinary >= 0.99
            break
        end
    end
    if last_index - j == first_index+1
        % Two points is not enough for regression
        error("Not found linear part with R2 >= 0.97");
    end
    result = struct('model', model, 'yield_index', last_index-j);
end