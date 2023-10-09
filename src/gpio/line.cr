class GPIO::Line
  def initialize(@chip : Chip, @offset : Int32)
    @to_unsafe = LibGPIOD.chip_get_line(@chip, @offset)
    @line = @to_unsafe.value
  end

  getter to_unsafe : Pointer(LibGPIOD::Line)
  @line : LibGPIOD::Line

  def to_s(io : IO)
    io << "gpio line"
    io << offset
    io << ": "
    io << name
  end

  def finalize
    LibGPIOD.line_release(@to_unsafe)
  end

  getter offset : Int32

  def direction
    @line.direction
  end

  getter name do
    String.new(@line.name.to_unsafe)
  end

  getter consumer do
    String.new(@line.consumer.to_unsafe)
  end

  def read
    result = LibGPIOD.line_get_value(self)
    raise "Reading #{self} failed" if result == -1
    result
  end

  def write(new_value : Int32)
    result = LibGPIOD.line_set_value(self, new_value)
    raise "Writing #{self} failed" if result == -1
    result
  end

  def set_high
    write(1)
  end

  def set_low
    write(0)
  end

  def high? : Bool
    read == 1
  end

  def low? : Bool
    read == 0
  end

  def requested? : Bool
    LibGPIOD.line_is_requested(self)
  end

  def free? : Bool
    LibGPIOD.line_is_free(self)
  end

  def consumer : String?
    chars = LibGPIOD.line_consumer(self)
    return nil if chars.null?
    String.new(chars)
  end

  getter? requested_by_us : Bool = false

  def request_input(consumer : String = GPIO.default_consumer)
    release
    raise "#{self} in use by '#{self.consumer}'" unless free?

    result = LibGPIOD.line_request_input(self, consumer)
    raise "request_input on #{self} failed" unless result.zero?
    @requested_by_us = true
    self
  end

  def request_output(consumer : String = GPIO.default_consumer)
    release
    raise "#{self} in use by '#{self.consumer}'" unless free?

    result = LibGPIOD.line_request_output(self, consumer)
    raise "request_output on #{self} failed" unless result.zero?
    @requested_by_us = true
    self
  end

  # grab IO events
  enum EventType
    Rising  = 1
    Falling = 2
  end

  @event_fd : IO::FileDescriptor? = nil

  def on_input_change(consumer : String = GPIO.default_consumer, & : EventType ->)
    release
    raise "#{self} in use by '#{self.consumer}'" unless free?

    result = LibGPIOD.line_request_both_edges_events(self, consumer)
    raise "request_output on #{self} failed" unless result.zero?
    @requested_by_us = true

    fd = LibGPIOD.line_event_get_fd(self)
    if fd == -1
      release
      raise "unknown issue obtaining file descriptor for #{self}"
    end

    line_event = LibGPIOD::LineEvent.new
    @event_fd = file = IO::FileDescriptor.new(fd)
    loop do
      break if file.closed?

      # perform non-blocking reads
      file.wait_readable
      result = LibGPIOD.line_event_read(self, pointerof(line_event))
      raise "failed to read line event on #{self}" unless result.zero?

      yield EventType.from_value(line_event.event_type)
    rescue error : IO::Error
      raise error if requested_by_us?
    end

    self
  ensure
    release
  end

  def release
    @requested_by_us = false
    @event_fd.try(&.close) rescue nil
    LibGPIOD.line_release(self)
    self
  end
end
