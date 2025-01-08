class GPIO::Line::Config
  def initialize
    @to_unsafe = LibGPIOD.line_config_new
    raise "failed to create line config" if @to_unsafe.null?
  end

  getter to_unsafe : LibGPIOD::LineConfig

  def finalize
    LibGPIOD.line_config_free @to_unsafe
  end

  def add_settings(offsets : Int | Array(Int), direction : LineDirection? = nil, edge_detection : LineEdge? = nil)
    offsets = (offsets.is_a?(Array) ? offsets : [offsets]).map(&.to_u32)
    settings = Line::Settings.new
    settings.direction = direction if direction
    settings.edge_detection = edge_detection if edge_detection
    success = LibGPIOD.line_config_add_line_settings(self, offsets, offsets.size, settings)
    raise "failed to add settings" unless success.zero?
    settings
  end

  def output_values(outputs : Array(LineValue)) : Nil
    success = LibGPIOD.line_config_set_output_values(self, outputs, outputs.size)
    raise "failed to configure output values" unless success.zero?
  end

  def output_value(output : LineValue) : Nil
    output_values([output])
  end
end
