"""
Design: S_REG_L
Author: Jirawat Iamsamang, Óscar Lecina Tejero
The code is a Python script that generates a G-code file for printing a 3D scaffold structure
using specific design and printing parameters. It includes calculations for various dimensions
and offsets, as well as functions for creating stabilization lines and generating the actual
printing paths. Additionally, the script outputs information such as the total size of the 
structure, the filename for the output G-code file, and details about the printing parameters.

It also includes comments to describe different sections of the code and provide context for
the operations being performed.

Parameters: A, B, X_repetitions, Y_repetitions, CTS, number_scaffold, offset_bw_scaffold, layers, uturn_length, uturn_radius, filename
"""
import math
import sys
import os
from os.path import basename

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from Strategy.layer_correction import LayerCorrection

#***** Design parameters from Images ****
A = 1.0/4       # [mm]
B = A           # [mm]
X_repetitions = 12 # number of unit cells in x-direction
Y_repetitions = 12 # number of unit cells in y-direction
# Note: 3 = 3mm,12 = 12mm (specimens for biaxial test)

#***** Printing parameters ******
CTS = 150          # [mm/min]
number_scaffold = 1 # number of scaffold
offset_bw_scaffold = 1 # [mm] offset between scaffold and structure
layers = 10         # [-] 
uturn_length = 6*A # [mm] length of uturn after printing horizontal unit cells
uturn_radius = 4*A # [mm] radius of uturn
LayerCorrection.enable = False

# checking the validity of parameters
tan = lambda deg : math.tan(math.radians(deg))
sin = lambda deg : math.sin(math.radians(deg))
cos = lambda deg : math.cos(math.radians(deg))
pore_size = 4*A # [mm]
assert X_repetitions > 0 and Y_repetitions > 0
assert uturn_radius >= pore_size

total_x = pore_size * X_repetitions
total_y = pore_size * Y_repetitions

print(f'Total size X*Y: {total_x}*{total_y} [mm^2]')

from datetime import datetime
today = datetime.now()
today_str = today.strftime('%Y%m%d')
filename = f'sregl_nL{layers}_cts{CTS}_{today_str}.gcode'
#filename = 'test.gcode'

print(f'Generating script for: {CTS} mm/min')
print(f'Filename: {filename}')

def stabilization_lines(f, wx, ystep=0.3, speed=CTS, n=5):
  f.write('; Stabilization line\n')
  f.write('; layer-correction: off\n')
  for i in range(n):
    f.write(f'G0 X{wx} F{speed}\n')
    f.write(f'G0 Y{ystep} F{speed}\n')
    f.write(f'G0 X{-wx} F{speed}\n')
    f.write(f'G0 Y{ystep} F{speed}\n\n')
  f.write(f'G0 Y{2*ystep} F{speed}\n\n')
  f.write('; layer-correction: on\n')

def main():
  with open(filename, 'w') as f:
    f.write(f'; S regular large\n')
    f.write(f'; Generated by {basename(__file__)}\n')
    f.write(f'; CTS: {CTS}\n')
    f.write(f'; A: {A}\n')
    f.write(f'; B: {B}\n')
    f.write(f'; pore_size: {pore_size}\n')
    f.write(f'; uturn_length: {uturn_length}\n')
    f.write(f'; uturn_radius: {uturn_radius}\n')
    f.write(f'; Y_repetitions: {Y_repetitions}\n')
    f.write(f'; X_repetitions: {X_repetitions}\n')
    f.write(f'; layers: {layers}\n')
    f.write(f'; total_x: {total_x}\n')
    f.write(f'; total_y: {total_y}\n')
    
    f.write(f'; start gcode\n')
    f.write(f'; Relative positioning\n')
    f.write(f'G91\n; start at bottom-left corner\nG0 X0 Y0\n\n')

    n = layers
    
    # printing the scaffold
    for s in range(number_scaffold):
      f.write(f'; START scaffold {s+1}/{number_scaffold}\n')
      stabilization_lines(f, total_x)
      for l in range(n):
        f.write(f"\n; START layer {l+1}/{n}\n")
        f.write(f'; current_layer: {l}\n')

        # Dynamic parameter calculation based on layers
        speed = LayerCorrection.new_speed(CTS, l)
        b = LayerCorrection.new_amplitude_offset(B, l)
        phase_offset = LayerCorrection.new_phase_offset(l)
        
        last_j = round(Y_repetitions/2) - 1
        f.write(f'; START Printing horizontally\n')
        for j in range(round(Y_repetitions/2)):
          f.write(f'G1 X{phase_offset} F{speed}\n')
          for i in range(X_repetitions):
            f.write(f'G1 X{A} Y{-b} F{speed}\n')
            f.write(f'G1 X{A} Y{b} F{speed}\n')
            f.write(f'G1 X{A} Y{b} F{speed}\n')
            f.write(f'G1 X{A} Y{-b} F{speed}\n')

          f.write(f'G1 X{uturn_length-phase_offset} F{speed}\n')
          f.write(f'G3 Y{pore_size} I{uturn_radius} J{pore_size/2} F{speed}\n')
          f.write(f'G1 X{-uturn_length} F{speed}\n')

          f.write(f'G1 X{-phase_offset} F{speed}\n')
          for i in range(X_repetitions):
            f.write(f'G1 X{-A} Y{b} F{speed}\n')
            f.write(f'G1 X{-A} Y{-b} F{speed}\n')
            f.write(f'G1 X{-A} Y{-b} F{speed}\n')
            f.write(f'G1 X{-A} Y{b} F{speed}\n')

          f.write(f'G1 X{-uturn_length+phase_offset} F{speed}\n')
          f.write(f'G2 Y{pore_size} I{-uturn_radius} J{pore_size/2} F{speed}\n')
          f.write(f'G1 X{uturn_length} F{speed}\n')

          if j == last_j:
            f.write(f'G1 X{phase_offset} F{speed}\n')
            for i in range(X_repetitions):
              f.write(f'G1 X{A} Y{-b} F{speed}\n')
              f.write(f'G1 X{A} Y{b} F{speed}\n')
              f.write(f'G1 X{A} Y{b} F{speed}\n')
              f.write(f'G1 X{A} Y{-b} F{speed}\n')
        f.write(f'; END Printing horizontally\n')

        f.write(f'G1 X{uturn_length-phase_offset} F{speed}\n')
        f.write(f'G1 Y{uturn_length} F{speed}\n')
        f.write(f'G1 X{-uturn_length} F{speed}\n')
        f.write(f'G1 Y{-uturn_length} F{speed}\n')
        
        
        f.write(f'; START Printing vertically\n')
        last_i = round(X_repetitions/2) - 1
        for i in range(round(X_repetitions/2)):
          f.write(f'G1 Y{-phase_offset} F{speed}\n')
          for j in range(round(Y_repetitions)):
            f.write(f'G1 X{-b} Y{-A} F{speed}\n')
            f.write(f'G1 X{b} Y{-A} F{speed}\n')
            f.write(f'G1 X{b} Y{-A} F{speed}\n')
            f.write(f'G1 X{-b} Y{-A} F{speed}\n')
          
          f.write(f'G1 Y{-uturn_length+phase_offset} F{speed}\n')
          f.write(f'G2 X{-pore_size} I{-pore_size/2} J{-uturn_radius} F{speed}\n')
          f.write(f'G1 Y{uturn_length} F{speed}\n')

          f.write(f'G1 Y{phase_offset} F{speed}\n')
          for j in range(round(Y_repetitions)):
            f.write(f'G1 X{b} Y{A} F{speed}\n')
            f.write(f'G1 X{-b} Y{A} F{speed}\n')
            f.write(f'G1 X{-b} Y{A} F{speed}\n')
            f.write(f'G1 X{b} Y{A} F{speed}\n')
          
          f.write(f'G1 Y{uturn_length-phase_offset} F{speed}\n')
          f.write(f'G3 X{-pore_size} I{-pore_size/2} J{uturn_radius} F{speed}\n')
          f.write(f'G1 Y{-uturn_length} F{speed}\n')

          if i == last_i:
            f.write(f'G1 Y{-phase_offset} F{speed}\n')
            for j in range(round(Y_repetitions)):
              f.write(f'G1 X{-b} Y{-A} F{speed}\n')
              f.write(f'G1 X{b} Y{-A} F{speed}\n')
              f.write(f'G1 X{b} Y{-A} F{speed}\n')
              f.write(f'G1 X{-b} Y{-A} F{speed}\n')

            f.write(f'G1 Y{-uturn_length+phase_offset}\n')
            f.write(f'G1 X{-uturn_length}\n')
            f.write(f'G1 Y{uturn_length}\n')
            f.write(f'G1 X{uturn_length}\n')
      if s < number_scaffold - 1:
        f.write(f'G0 Y{-3.6} F{CTS}\n')
        f.write(f'G0 X{total_x + 2*uturn_length + 2*uturn_radius + offset_bw_scaffold} F{CTS}\n\n')
      else:
        f.write(f'G0 Y-3.6 X-3 F{CTS}\n')
      f.write(f'; END scaffold {s+1}\n')
    f.write(f'G90\n\n')
    f.write(f'M42 P0 S0\n')
    f.write(f'G0 Z10\n')
    f.write(f'; end gcode\n')

if __name__ == '__main__':
  main()