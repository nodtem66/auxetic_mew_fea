"""
Design: S_TRI
Author: Jirawat Iamsamang, Óscar Lecina Tejero
Date: 2024-03-04
Parameters: A, B, X_repetitions, Y_repetitions, CTS, number_scaffold, offset_bw_scaffold, layers, zero_degrees_length, sixty_dg_length, filename
"""
import math
import sys
from os.path import basename
import os
from datetime import datetime

# Import PrintStrategy
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from Strategy.layer_correction import LayerCorrection
from Strategy.print_transformation import PrintTransformation

# ***** Design parameters from Images ****
A = 0.25  # [mm]
B = 0.1875  # [mm]
X_repetitions = 4  # number of unit cells in x-direction
Y_repetitions = 4  # number of unit cells in y-direction
# note: 12 = 12mm, 24 = 24mm, 48 = 48mm, 96 = 96mm

# ***** Printing parameters ******
CTS = 100  # [mm/min]
layers = 10  # [-]
number_scaffold = 1  # number of scaffold
offset_bw_scaffold = 2  # [mm] offset between scaffold and structure
zero_degrees_length = 8 * A  # [mm] length of uturn after printing horizontal lines
sixty_dg_length = 12 * A  # [mm] length of uturn after printing +- 60 degrees lines
LayerCorrection.enable = False

# checking the validity of parameters
tan = lambda deg: math.tan(math.radians(deg))
sin = lambda deg: math.sin(math.radians(deg))
cos = lambda deg: math.cos(math.radians(deg))
triangle_side = 4 * A  # [mm]
triangle_dx = cos(60) * triangle_side
triangle_dy = sin(60) * triangle_side
assert X_repetitions > 0 and Y_repetitions > 0

if Y_repetitions % 2 == 0:
  odd_Y = False  # Y_repetitions is an even number
else:
  odd_Y = True  # Y_repetitions is an odd number

if X_repetitions % 2 == 0:
  odd_X = False  # X_repetitions is an even number
else:
  odd_X = True  # X_repetitions is an odd number

if int(Y_repetitions / 2) % 2 == 0:
  odd_y = False  # half of Y_repetitions is an even number
else:
  odd_y = True  # half of Y_repetitions is an odd number

xy_ratio = X_repetitions / int(Y_repetitions / 2)  # 1 if X=Y / <1 if X<Y / >1 if X>Y

total_x = triangle_side * X_repetitions
total_y = triangle_side * Y_repetitions

print(f'Total size (W*H): {total_x}*{total_y} [mm^2]')

today = datetime.now()
today_str = today.strftime('%Y%m%d')
filename = f'stri_nL{layers}_cts{CTS}_{today_str}.gcode'

print(f'Generating script for: {CTS} mm/min')
print(f'Filename: {filename}')

def zero_degrees_printing(f, B=B, pharse_offset=0, speed=CTS):
  f.write(f'; START Printing horizontally\n')

  index_j = int(Y_repetitions / 2) + 1 if odd_Y else int(Y_repetitions / 2)

  for j in range(index_j):
    f.write(f'G1 X{pharse_offset} F{speed}\n')
    for i in range(X_repetitions):
      f.write(f'G1 X{A} Y{-B} F{speed}\n')
      f.write(f'G1 X{A} Y{B} F{speed}\n')
      f.write(f'G1 X{A} Y{B} F{speed}\n')
      f.write(f'G1 X{A} Y{-B} F{speed}\n')

    f.write(f'G0 X{zero_degrees_length - pharse_offset} F{speed}\n')
    f.write(f'G0 Y{triangle_dy} F{speed}\n')
    f.write(f'G0 X{-zero_degrees_length + triangle_dx} F{speed}\n')

    f.write(f'G1 X{-pharse_offset} F{speed}\n')
    for i in range(X_repetitions):
      f.write(f'G1 X{-A} Y{B} F{speed}\n')
      f.write(f'G1 X{-A} Y{-B} F{speed}\n')
      f.write(f'G1 X{-A} Y{-B} F{speed}\n')
      f.write(f'G1 X{-A} Y{B} F{speed}\n')

    f.write(f'G0 X{-zero_degrees_length - triangle_dx + pharse_offset} F{speed}\n')
    f.write(f'G0 Y{triangle_dy} F{speed}\n')
    f.write(f'G0 X{zero_degrees_length} F{speed}\n')

  if odd_Y:
    f.write(f'G0 X{triangle_side * (X_repetitions - 1)} F{speed}\n')
    f.write(f'G0 X{triangle_dx} Y{-triangle_dy} F{speed}\n')
  else:
    f.write(f'G1 X{pharse_offset} F{speed}\n')
    for i in range(X_repetitions):
      f.write(f'G1 X{A} Y{-B} F{speed}\n')
      f.write(f'G1 X{A} Y{B} F{speed}\n')
      f.write(f'G1 X{A} Y{B} F{speed}\n')
      f.write(f'G1 X{A} Y{-B} F{speed}\n')
    f.write(f'G1 X{-pharse_offset} F{speed}\n')

  f.write(f'; END Printing horizontally\n')


def relocate_A(f, speed=CTS):
  f.write(f'; move to top-left corner\n')
  f.write(f'G0 X{- zero_degrees_length} F{speed}\n')
  f.write(f'G0 Y{triangle_dy * (Y_repetitions + 1)} F{speed}\n')
  if odd_Y:
    f.write(f'G0 X{zero_degrees_length + triangle_side} F{speed}\n')
  else:
    f.write(f'G0 X{zero_degrees_length + triangle_side + triangle_dx} F{speed}\n')
  f.write(f'G0 X{-triangle_dx} Y{-triangle_dy} F{speed}\n')


def relocate_B(f, sign, speed=CTS):
  f.write(f'; move to bottom-left corner\n')
  if sign < 0:
    f.write(f'G0 Y{- zero_degrees_length} F{speed}\n')
    f.write(f'G0 X{- triangle_side * X_repetitions - zero_degrees_length} F{speed}\n')
    f.write(f'G0 Y{zero_degrees_length} F{speed}\n')
    f.write(f'G0 X{zero_degrees_length} F{speed}\n')
  else:
    f.write(f'G0 X{zero_degrees_length} F{speed}\n')
    f.write(f'G0 Y{- zero_degrees_length} F{speed}\n')
    f.write(f'G0 X{- triangle_side * X_repetitions - 2 * zero_degrees_length - triangle_dx} F{speed}\n')
    f.write(f'G0 Y{zero_degrees_length - triangle_dy} F{speed}\n')
    f.write(f'G0 X{zero_degrees_length} F{speed}\n')


def sixty_degrees_printing_A(f, B, phase_offset=0, speed=CTS):
  f.write(f'; START Printing -60deg\n')
  t = PrintTransformation(f)
  t.set_rotate_angle(-60)

  def extra_lines(case):
    if case == '':
      f.write('; ERROR\n')
    else:
      f.write(f'; extra line {case}\n')
      if case == 'up':
        x = sign * -sixty_dg_length + sign * triangle_dx
      if case == 'right':
        x = sign * -sixty_dg_length + sign * triangle_dx + sign * triangle_side
      if case == 'up_corner':
        x = sign * -sixty_dg_length + sign * triangle_dx - sign * triangle_side
      if case == 'bottom_corner':
        x = sign * -sixty_dg_length + sign * triangle_dx
      if case == 'left':
        x = sign * -sixty_dg_length + sign * triangle_dx - 2 * sign * triangle_side
      if case == 'bottom':
        x = sign * -sixty_dg_length + sign * triangle_dx - sign * triangle_side
      t.write(f'G0 X{x} F{speed}\n')

  total_i = int(Y_repetitions / 2) + X_repetitions
  last_i = total_i

  diagonal_length = 2 * X_repetitions + 1 if xy_ratio < 1 else Y_repetitions

  loop_range = range(1, total_i + 1)

  for i in loop_range:
    f.write(f'; Printing -60deg lines: {i}/{total_i}\n')

    sign = -1 if i % 2 == 0 else 1

    if odd_Y:
      start_limit = 2 * i
    else:
      start_limit = 2 * i - 1

    end_limit = int(Y_repetitions / 2) if xy_ratio >= 1 else X_repetitions

    inner_step = start_limit if start_limit < diagonal_length else diagonal_length

    if i > last_i - end_limit:
      if diagonal_length % 2 == 0:
        inner_step -= 2 * (i - (last_i - end_limit) - 1)
      else:
        inner_step -= 2 * (i - (last_i - end_limit)) - 1

    f.write(f'; inner step: {inner_step}\n')
    t.write(f'G1 X{sign * phase_offset} F{speed}\n')
    for j in range(inner_step):
      t.write(f'G1 X{sign * A} Y{sign * -B} F{speed}\n')
      t.write(f'G1 X{sign * A} Y{sign * B} F{speed}\n')
      t.write(f'G1 X{sign * A} Y{sign * B} F{speed}\n')
      t.write(f'G1 X{sign * A} Y{sign * -B} F{speed}\n')

    # Print extra-scaffold lines
    t.write(f'G0 X{sign * sixty_dg_length - sign * phase_offset} F{speed}\n')

    offset_factor = 13 / 15
    t.write(f'G0 Y{- 4 * A * offset_factor} F{speed}\n')

    if i % 2 == 0:
      odd_i = False
    else:
      odd_i = True

    case = ''

    if xy_ratio < 1:
      if i < X_repetitions and i < int(Y_repetitions / 2):
        case = 'right' if odd_i else 'up'
      elif i == X_repetitions:
        if odd_X:
          case = 'right'
        else:
          case = 'up_corner' if odd_Y else 'up'
      elif X_repetitions < i < int(Y_repetitions / 2):
        case = 'right' if odd_i else 'left'
      elif i == int(Y_repetitions / 2):
        case = 'bottom_corner' if odd_y else 'left'
      else:
        case = 'bottom' if odd_i else 'left'

    else:  # xy_ratio >= 1:
      if i < X_repetitions and i < int(Y_repetitions / 2):
        case = 'right' if odd_i else 'up'
      elif i == int(Y_repetitions / 2):
        case = 'up'
      elif int(Y_repetitions / 2) < i < X_repetitions:
        case = 'bottom' if odd_i else 'up'
      elif i == X_repetitions:
        if odd_X:
          case = 'bottom'
        else:
          case = 'up_corner' if odd_Y else 'up'
      else:
        case = 'bottom' if odd_i else 'left'

    extra_lines(case)

  # [End] print extra-scaffold lines
  f.write(f'; END Printing -60deg\n\n')


def sixty_degrees_printing_B(f, B, phase_offset=0, speed=CTS):
  f.write(f'; START Printing +60deg\n')
  t = PrintTransformation(f)
  t.set_rotate_angle(60)

  def extra_lines(case):
    if case == '':
      f.write('; ERROR\n')
    else:
      f.write(f'; extra line {case}\n')
      if case == 'up':
        x = sign * -sixty_dg_length + sign * triangle_dx
      if case == 'right':
        x = sign * -sixty_dg_length + sign * triangle_dx - 2 * sign * triangle_side
      if case == 'up_corner':
        x = sign * -sixty_dg_length + sign * triangle_dx - sign * triangle_side
      if case == 'bottom_corner':
        x = sign * -sixty_dg_length + sign * triangle_dx
      if case == 'left':
        x = sign * -sixty_dg_length + sign * triangle_dx + sign * triangle_side
      if case == 'bottom':
        x = sign * -sixty_dg_length + sign * triangle_dx - sign * triangle_side
      t.write(f'G0 X{x} F{speed}\n')

  total_i = int(Y_repetitions / 2) + X_repetitions if not odd_Y else int(Y_repetitions / 2) + X_repetitions + 1
  last_i = total_i

  diagonal_length = 2 * X_repetitions + 1 if xy_ratio < 1 else Y_repetitions

  loop_range = range(1, total_i + 1)

  for i in loop_range:
    f.write(f'; Printing +60deg lines: {i}/{total_i}\n')

    sign = 1 if i % 2 == 0 else -1

    if odd_Y:
      start_limit = 2 * i - 1
    else:
      start_limit = 2 * i

    end_limit = int(Y_repetitions / 2) if xy_ratio >= 1 else X_repetitions

    inner_step = start_limit if start_limit < diagonal_length else diagonal_length

    if i > last_i - end_limit:
      if diagonal_length % 2 == 0:
        inner_step -= 2 * (i - (last_i - end_limit)) - 1
      else:
        inner_step -= 2 * (i - (last_i - end_limit))

    f.write(f'; inner step: {inner_step}\n')
    t.write(f'G1 X{sign * phase_offset} F{speed}\n')
    for j in range(inner_step):
      t.write(f'G1 X{sign * A} Y{sign * -B} F{speed}\n')
      t.write(f'G1 X{sign * A} Y{sign * B} F{speed}\n')
      t.write(f'G1 X{sign * A} Y{sign * B} F{speed}\n')
      t.write(f'G1 X{sign * A} Y{sign * -B} F{speed}\n')

    # Print extra-scaffold lines
    offset_factor = 13 / 15
    if i != last_i:
      t.write(f'G0 X{sign * sixty_dg_length - sign * phase_offset} F{speed}\n')
      t.write(f'G0 Y{- 4 * A * offset_factor} F{speed}\n')
    else:
      t.write(f'G0 X{-sign * phase_offset} F{speed}\n')

    if i % 2 == 0:
      odd_i = False
    else:
      odd_i = True

    case = ''

    if xy_ratio < 1:
      if i < X_repetitions and i < int(Y_repetitions / 2):
        case = 'left' if odd_i else 'up'
      elif i == X_repetitions:
        if odd_X:
          case = 'left'
        else:
          case = 'up' if odd_Y else 'up_corner'
      elif X_repetitions < i < int(Y_repetitions / 2):
        case = 'left' if odd_i else 'right'
      elif i == int(Y_repetitions / 2):
        if not odd_y:
          case = 'right'
        else:
          case = 'left' if odd_Y else 'bottom'
      else:
        case = 'bottom' if odd_i else 'right'

    else:  # elif xy_ratio >= 1:
      if i < X_repetitions and i < int(Y_repetitions / 2):
        case = 'left' if odd_i else 'up'
      elif i == int(Y_repetitions / 2):
        if odd_y:
          case = 'left' if odd_Y else 'bottom'
        else:
          case = 'up'
      elif int(Y_repetitions / 2) < i < X_repetitions:
        case = 'bottom' if odd_i else 'up'
      elif i == X_repetitions:
        if odd_X:
          case = 'bottom'
        else:
          case = 'up' if odd_Y else 'up_corner'
      else:
        case = 'bottom' if odd_i else 'right'

    if i != last_i:
      extra_lines(case)
    else:
      relocate_B(f, sign, speed=speed)


def stabilization_lines(f, wx, ystep=0.3, speed=CTS, n=5):
  f.write('; Stabilization line\n')
  f.write('; layer-correction: off\n')
  for i in range(n):
    f.write(f'G0 X{wx} F{speed}\n')
    f.write(f'G0 Y{ystep} F{speed}\n')
    f.write(f'G0 X{-wx} F{speed}\n')
    f.write(f'G0 Y{ystep} F{speed}\n\n')
  f.write(f'G0 Y{2 * ystep} F{speed}\n\n')
  f.write('; layer-correction: on\n')

def main():
  with open(filename, 'w') as f:
    f.write(f'; S Triangular\n')
    f.write(f'; Generated by {basename(__file__)}\n')
    f.write(f'; CTS: {CTS}\n')
    f.write(f'; A: {A}\n')
    f.write(f'; B: {B}\n')
    f.write(f'; pore_size: {triangle_side}\n')
    f.write(f'; zero_degrees_length: {zero_degrees_length}\n')
    f.write(f'; sixty_degrees_length: {sixty_dg_length}\n')
    f.write(f'; Y_repetitions: {Y_repetitions}\n')
    f.write(f'; X_repetitions: {X_repetitions}\n')
    f.write(f'; layers: {layers}\n')
    f.write(f'; total_x: {total_x}\n')
    f.write(f'; total_y: {total_y}\n')

    f.write(f'; start gcode\n')
    f.write(f'; Relative positioning\n')
    f.write(f'G91\n; start at bottom-left corner\nG0 X0 Y0\n\n')

    stabilization_ystep = 0.3
    stabilization_n = 5

    # printing the construct
    n = layers
      
    # Print all scaffold
    for s in range(number_scaffold):
      f.write(f'; START scaffold {s+1}/{number_scaffold}\n')
      stabilization_lines(f, total_x, stabilization_ystep, CTS, stabilization_n)
      # Print one scaffold
      for layer in range(n):
        speed = LayerCorrection.new_speed(CTS, layer)
        b = LayerCorrection.new_amplitude_offset(B, layer)
        phase_offset = LayerCorrection.new_phase_offset(layer)
        
        f.write(f"\n; START layer {layer + 1}/{n}\n")
        f.write(f'; current_layer: {layer}\n')
        
        zero_degrees_printing(f, b, phase_offset, speed)
        sixty_degrees_printing_A(f, b, phase_offset, speed)
        relocate_A(f)
        sixty_degrees_printing_B(f, b, phase_offset, speed)

      f.write(f'G1 Y{-2 * stabilization_ystep * (stabilization_n+1)} F{CTS}\n')
      if s < number_scaffold - 1:
        f.write(f'G0 X{total_x + offset_bw_scaffold + zero_degrees_length} F{CTS}\n')
      f.write(f'; END scaffold {s+1}/{number_scaffold}\n')
    f.write(f'G90\n\n')
    f.write(f'M42 P0 S0\n')
    f.write(f'G0 Z10\n')
    f.write(f'; end gcode\n')

if __name__ == '__main__':
  main()