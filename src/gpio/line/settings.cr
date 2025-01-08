class GPIO::Line::Settings
  def initialize
    @to_unsafe = LibGPIOD.line_settings_new
    raise "failed to create line settings" if @to_unsafe.null?
  end

  getter to_unsafe : LibGPIOD::LineSettings

  def finalize
    LibGPIOD.line_settings_free @to_unsafe
  end

  property direction : LineDirection = LineDirection::AS_IS

  def direction=(value : LineDirection)
    success = LibGPIOD.line_settings_set_direction(self, value)
    raise "failed to set direction" unless success.zero?
    @direction = value
  end

  property edge_detection : LineEdge = LineEdge::NONE

  def edge_detection=(value : LineEdge)
    success = LibGPIOD.line_settings_set_edge_detection(self, value)
    raise "failed to set edge detection" unless success.zero?
    @edge_detection = value
  end
end
