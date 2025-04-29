class LayerCorrection:
  enable = False
  enable_speed = True
  enable_amplitude = True
  enable_phase = True
  # New speed
  @staticmethod
  def new_speed(CTS, layer):
    if not LayerCorrection.enable or not LayerCorrection.enable_speed:
      return CTS
    assert layer >= 0, 'layer must be >= 0'
    if layer <= 15:
      decreased_speed = 0.018 * layer * CTS
    else:
      decreased_speed = 0.023 * layer * CTS
    return CTS - decreased_speed
  
  # Amplitude offset
  @staticmethod
  def new_amplitude_offset(initial_amplitude, layer):
    if not LayerCorrection.enable or not LayerCorrection.enable_amplitude:
      return initial_amplitude
    assert layer >= 0, 'layer must be >= 0'
    return initial_amplitude * (1 + 0.045 * layer)
  
  # Phase shift
  @staticmethod
  def new_phase_offset(layer):
    if not LayerCorrection.enable or not LayerCorrection.enable_phase:
      return 0
    assert layer >= 0, 'layer must be >= 0'
    return 0.005 * layer