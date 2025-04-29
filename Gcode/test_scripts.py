# -*- coding: utf-8 -*-
"""
Test script for generating G-code files using various patterns.
This script imports the necessary modules and defines a test case for each pattern generation script.
It runs each script and checks if the G-code file is created successfully.
author: Jirawat Iamsamang (github.com/nodtem66)
"""

import unittest
import sys
import os
import pathlib

parent_path = pathlib.Path(__file__).parent
custom_paths = ['Arrowhead', 'S-regular']
for path in custom_paths:
    sys.path.append(os.path.join(parent_path, path))

TEST_GCODE = 'test.gcode'

def handle_script(script_name, unittest_instance):
    """Handle the script execution and cleanup."""
    try:
        print()
        script_module = __import__(script_name)
        script_module.filename = TEST_GCODE
        script_module.main()
        unittest_instance.assertTrue(True)
    except Exception as e:
        print(f"Error running {script_name}: {e}")
        unittest_instance.fail(f"{script_name} failed to run.")
    finally:
        if os.path.exists(TEST_GCODE):
            os.remove(TEST_GCODE)


class TestScripts(unittest.TestCase):
    def test_hcell_script(self):
        handle_script('generate_h_cell', self)

    def test_sinv_script(self):
        handle_script('generate_s-inverted-small', self)

    def test_sregular_script(self):
        handle_script('generate_s-regular-large', self)
        handle_script('generate_s-regular-small', self)

    def test_stri_script(self):
        handle_script('generate_s-triangular', self)

    def test_arrowhead_script(self):
        handle_script('generate_arrowhead', self)
        handle_script('generate_arrowhead_diagonal', self)
        handle_script('generate_arrowhead_horizontal', self)
        handle_script('generate_arrowhead_with_loop', self)

if __name__ == '__main__':
    sys.stdout = open('test_scripts.log', 'w')
    tests = unittest.TestLoader().loadTestsFromTestCase(TestScripts)
    unittest.TextTestRunner(stream=sys.stdout, verbosity=2).run(tests)