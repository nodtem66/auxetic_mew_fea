%% Analyse the tensile data from *.mat in x direction
% Only the designs with layer correction will be used
% hcell
% sinv_correct
% stri_correct
% sreg_correct
clc; close all; clear;

%% Load data
hcell1 = load("hcell_1.mat");
hcell2 = load("hcell_2.mat");
hcell3 = load("hcell_3.mat");

sinv1 = load("sinv_correct_1.mat");
sinv2 = load("sinv_correct_2.mat");
sinv3 = load("sinv_correct_3.mat");

sreg1 = load("sreg_correct_1.mat");
sreg2 = load("sreg_correct_2.mat");
sreg3 = load("sreg_correct_3.mat");

stri1 = load("stri_correct_001.mat");
stri2 = load("stri_correct_002.mat");
stri3 = load("stri_correct_003.mat");

%%
dataset = {hcell1, hcell2, hcell3, ...
    sinv1, sinv2, sinv3,...
    sreg1, sreg2, sreg3,...
    stri1, stri2, stri3};

start_stress = [40, 40, 40, ...
    10, 10, 10, ...
    10, 10, 10, ...
    10, 10, 10];

yield_strain = zeros(length(dataset), 1);
yield_stress_kPa = zeros(size(yield_strain));
stiffness_kPa = zeros(size(yield_strain));
strain_energy = zeros(size(yield_strain));

for i = 1:length(dataset)
    d = dataset{i};
    origin_stress = d.XStress_kPa;
    d.XStress_kPa = smooth(d.XStress_kPa, 20);
    first_index = find(d.XStress_kPa >= start_stress(i), 1, 'first');
    last_index = find(d.XStrain >= 2.3, 1, 'first');
    fit_result = find_best_lm(d.XStrain, d.XStress_kPa, first_index, last_index);
    figure;
    hold on;
    title(i);
    plot(d.XStrain, origin_stress, 'g.');
    plot(d.XStrain, d.XStress_kPa, 'k-');
    plot(d.XStrain(first_index), d.XStress_kPa(first_index), 'r*');
    plot(d.XStrain(fit_result.yield_index), d.XStress_kPa(fit_result.yield_index), 'b*');
    
    last_index = fit_result.yield_index;
    yield_strain(i) = d.XStrain(last_index);
    yield_stress_kPa(i) = origin_stress(last_index);
    stiffness_kPa(i) = fit_result.model.Coefficients.Estimate(1);
    strain_energy(i) = trapz(d.XStrain(first_index:last_index), d.XStress_kPa(first_index:last_index));
end

%% Init table
dataset_label = {'hcell'; 'hcell'; 'hcell';...
    'sinv'; 'sinv'; 'sinv'; ...
    'sreg'; 'sreg'; 'sreg'; ...
    'stri'; 'stri'; 'stri'};
dataset_label = categorical(dataset_label);
if exist("t", "var")
    t = [t; table(dataset_label, yield_stress_kPa, yield_strain, stiffness_kPa, strain_energy)];
else
    t = table(dataset_label, yield_stress_kPa, yield_strain, stiffness_kPa, strain_energy);
end

%% Save table
writetable(t, 'all_x.csv');

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