class GPIO::Line::Request
  class Ref
    def initialize(@to_unsafe : LibGPIOD::LineRequest)
    end

    getter to_unsafe : LibGPIOD::LineRequest
    getter? released : Bool = false

    def finalize
      LibGPIOD.line_request_release(@to_unsafe) unless @released
    end

    def release
      return if @released
      @released = true
      LibGPIOD.line_request_release(@to_unsafe)
    end
  end

  def initialize(@chip : Chip, @line : Line, request : LibGPIOD::LineRequest, @consumer : Line::RequestConfig, @config : Line::Config)
    @ref = Ref.new request
  end

  def to_unsafe
    @ref.to_unsafe
  end

  def released?
    @ref.released?
  end

  def release
    @ref.release
  end

  protected def raise_if_released
    raise "line has already been released" if released?
  end

  def set_value(value : LineValue, offset : Int = @line.offset)
    raise_if_released
    success = LibGPIOD.line_request_set_value(self, offset.to_u32, value)
    raise "failed to set line #{offset} to #{value}" unless success.zero?
    value
  end

  def values=(values : Array(LineValue))
    raise_if_released
    success = LibGPIOD.line_request_set_values(self, values)
    raise "failed to set line values" unless success.zero?
    value
  end

  def get_value(offset : Int = @line.offset)
    raise_if_released
    LibGPIOD.line_request_get_value(self, offset.to_u32)
  end

  getter buffer : Line::EventBuffer { Line::EventBuffer.new }

  def read_edge_event : Line::Event
    raise_if_released
    success = LibGPIOD.line_request_read_edge_events(self, buffer, 1)
    raise "failed to read event" unless success > 0
    buffer.get_event
  end

  def file_descriptor
    raise_if_released
    IO::FileDescriptor.new(LibGPIOD.line_request_get_fd(self), close_on_finalize: false)
  end

  def watch_events(& : EdgeEventType ->)
    file = file_descriptor
    loop do
      break if file.closed?

      # perform non-blocking reads
      file.wait_readable
      yield read_edge_event.event_type
    end
  end
end
