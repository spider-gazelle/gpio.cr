class GPIO::Line::EventBuffer
  def initialize(size : Int = 1)
    @size = size.to_i
    @to_unsafe = LibGPIOD.edge_event_buffer_new(@size)
    raise "failed to create line config" if @to_unsafe.null?
  end

  getter to_unsafe : LibGPIOD::EdgeEventBuffer
  getter size : Int32

  def finalize
    LibGPIOD.edge_event_buffer_free @to_unsafe
  end

  def get_event(index : Int = 0)
    raise IndexError.new("out of range, buffer size #{size}, requested #{index}") unless index >= 0 && index < size
    index = index.to_u32
    event = LibGPIOD.edge_event_buffer_get_event(self, index)
    raise "failed to obtain event" if event.null?
    # we need to make a copy as we can't free any memory allocated by the buffer
    Line::Event.new LibGPIOD.edge_event_copy(event)
  end
end
