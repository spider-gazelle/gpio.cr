class GPIO::Line::Event
  def initialize(event : LibGPIOD::EdgeEvent)
    @to_unsafe = event
  end

  getter to_unsafe : LibGPIOD::EdgeEvent

  def finalize
    LibGPIOD.edge_event_free @to_unsafe
  end

  getter event_type : EdgeEventType do
    LibGPIOD.edge_event_get_event_type(self)
  end

  getter line_offset : Int32 do
    LibGPIOD.edge_event_get_line_offset(self).to_i
  end
end
