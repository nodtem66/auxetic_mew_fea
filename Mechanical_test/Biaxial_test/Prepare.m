% Clear
clc; clear; close all;
addpath("../Draft/Scripts/");

%% Scan all meta.json
meta_files = dir(fullfile("./", "**", "meta.json"));
n_file = length(meta_files);
for i = 1:n_file
    fprintf("Found %s\n", meta_files(i).folder);
end

%% Remove all old mats
n_file = length(meta_files);
for i = 1:n_file
    delete(fullfile(meta_files(i).folder, "*.mat"));
end

%% Load HCELL data
n_file = length(meta_files);
for i = 1:n_file
    folder = meta_files(i).folder;
    fprintf("Processed %s\n", folder);

    assert(isfolder(folder), "%s is not a folder", folder);
    
    meta_file = fullfile(folder, "meta.json");
    meta_info = readstruct(meta_file);
    
    assert(isfield(meta_info, "biotester_csv"), "missing field biotester_csv");
    assert(isfield(meta_info, "thickness_um"), "missing field thicknesss_um");
    
    thickness_um = mean(meta_info.thickness_um);
    width_mm = 5;
    area_mm2 = thickness_um / 1000 * width_mm; 
    
    biotester_csv = fullfile(folder, meta_info.biotester_csv);
    assert(isfile(biotester_csv), "%s is not a file", biotester_csv);
    biotester_data = readtable(biotester_csv);
    
    %start_index = find(biotester_data.XForce_mN >= 0, 1, 'first');
    start_index = 1;
    initial_displacement_x = biotester_data.XSize_um(start_index);
    XStrain = biotester_data.XSize_um(start_index:end)./initial_displacement_x - 1;
    XStress_kPa = biotester_data.XForce_mN(start_index:end) ./ area_mm2; 
    
    %start_index = find(biotester_data.YForce_mN >= 0, 1, 'first');
    start_index = 1;
    initial_displacement_y = biotester_data.YSize_um(start_index);
    YStrain = biotester_data.YSize_um(start_index:end)./initial_displacement_y - 1;
    YStress_kPa = biotester_data.YForce_mN(start_index:end) ./ area_mm2;
    % 
    % plot(XStrain, XStress_kPa, 'r.-');
    % hold on;
    % plot(YStrain, YStress_kPa, 'k.-');
    % legend("X", "Y");
    
    mat_file = fullfile(folder, sprintf("%s.mat", meta_info.name));
    save(mat_file, "meta_info", "thickness_um", "area_mm2", "XStress_kPa", "XStrain", "YStress_kPa", "YStrain");
end


%% Copy all mats to current dir
n_file = length(meta_files);
for i = 1:n_file
    copyfile(fullfile(meta_files(i).folder, "*.mat"));
end