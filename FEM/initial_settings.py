"""
AUXETIC SCAFFOLD FEM MODEL - DESIGN PARAMETERS DEFINITION SCRIPT

    Defines the design and its parameters for each case.

    Writes each combination in a .txt file to be read by the main script.

    Design is defined by updating the 'designs' dictionary at the corresponding design with its parameters.
        - 'arrowhead' and 'hcell_uniform' designs are only defined as "uniform", meaning that their fiber walls are
        stacked vertically without shifting.
        - The other designs ('sreg', 'sinv', and 'stri') can be defined as "uniform" or "shifted", meaning that their
        fiber walls will be stacked vertically with or without a shift in the transverse direction, which can be
        modified in the model generation script (create_aux_str.py) if needed, being set by default as a reduction of
        parameter B of 5% for each layer.

    Defining more than one parameter in any case will generate all possible combinations.

    Parameters (8):
        - A (float): Geometry parameter A, different meaning for each design, but always defined in microns [10^-3 mm].
        - B (float): Geometry parameter B, different meaning for each design, always defined in microns [10^-3 mm]
         except for the 'arrowhead' design, where it is defined as an angle [º].
        - D (float): Fiber diameter in microns [10^-3 mm].
        - XR (int): Number of repetitions of the basic design unit in the x-direction.
        - YR (int):Number of repetitions of the basic design unit in the y-direction.
        - ZR (int): Number of layers stacked in the z-direction.

    At the end, each combination will have assigned a unique numerical identifier, starting from 00001.

"""

import os
from itertools import product

# ---------------------------------------------------------------
# Design Parameters Structure:

common_parameters = {
    'A': [],
    'B': [],
    'D': [12],
    'XR': [],
    'YR': [],
    'ZR': [10]
}

# ---------------------------------------------------------------
# Designs Dictionary:

designs = {
    'arrowhead': dict(common_parameters),
    'hcell_uniform': dict(common_parameters),
    'stri_uniform': dict(common_parameters),
    'stri_shift': dict(common_parameters),
    'sreg_uniform': dict(common_parameters),
    'sreg_shift': dict(common_parameters),
    'sinv_uniform': dict(common_parameters),
    'sinv_shift': dict(common_parameters),
}

# ---------------------------------------------------------------
# Update values for each design:

designs['arrowhead'].update({
    'A': [650],
    'B': [75],
    'D': [20],
    'XR': [8],
    'YR': [8]
})

designs['hcell_uniform'].update({
    'A': [150],
    'B': [250],
    'XR': [3],
    'YR': [3]
})

designs['stri_uniform'].update({
    'A': [250],
    'B': [187.5],
    'XR': [4],
    'YR': [4]
})

designs['stri_shift'].update({
    'A': [250],
    'B': [187.5],
    'XR': [4],
    'YR': [4]
})

designs['sreg_uniform'].update({
    'A': [250],
    'B': [250],
    'XR': [3],
    'YR': [3]
})

designs['sreg_shift'].update({
    'A': [125],
    'B': [125],
    'XR': [6],
    'YR': [6]
})

designs['sinv_uniform'].update({
    'A': [250],
    'B': [187.5],
    'XR': [3],
    'YR': [3]
})

designs['sinv_shift'].update({
    'A': [250],
    'B': [187.5],
    'XR': [3],
    'YR': [3]
})

# ---------------------------------------------------------------
# Write all the models defined in a .txt file:

summary_file_name = 'inputs.txt'

# Remove files if exist
try:
    os.remove(summary_file_name)
except OSError:
    pass

with open(summary_file_name, 'w') as input_file:
    n_case = 1  # model identifier (id)
    for design, parameters in designs.items():
        combinations = list(product(*parameters.values()))
        for combination in combinations:
            line = ', '.join(map(str, combination))

            input_file.write(f"{design}, {line}, {str(n_case).zfill(5)}\n")

            n_case += 1

# ---------------------------------------------------------------