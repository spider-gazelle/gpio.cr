require "./lib_gpiod"

class GPIO::Line
  class Ref
    def initialize(@to_unsafe : LibGPIOD::LineInfo)
    end

    getter to_unsafe : LibGPIOD::LineInfo

    def finalize
      LibGPIOD.line_info_free(@to_unsafe)
    end
  end

  def initialize(@chip : Chip, @offset : Int32)
    @ref = Ref.new LibGPIOD.chip_get_line_info(@chip, @offset)
  end

  def to_unsafe : LibGPIOD::LineInfo
    @ref.to_unsafe
  end

  def to_s(io : IO)
    io << "gpio line"
    io << offset
    io << ": "
    io << name
  end

  getter chip : Chip
  getter offset : Int32
  getter? requested_by_us : Bool = false
  @request : Line::Request? = nil

  protected def get_request! : Line::Request
    request = @request
    raise "input or output mode must be requested" unless request
    request
  end

  getter name : String do
    pointer = LibGPIOD.line_info_get_name(self)
    pointer.null? ? @offset.to_s : String.new(pointer)
  end

  def consumer : String?
    pointer = LibGPIOD.line_info_get_consumer(self)
    pointer.null? ? nil : String.new(pointer)
  end

  def in_use? : Bool
    LibGPIOD.line_info_is_used(self)
  end

  def direction
    LibGPIOD.line_info_get_direction(self)
  end

  def edge_detection
    LibGPIOD.line_info_get_edge_detection(self)
  end

  protected def request_exclusive_access(direction : LineDirection, consumer : String? = nil, edge_detection : LineEdge? = nil)
    raise "already requested" if @requested_by_us
    @requested_by_us = true

    req_config = consumer.presence ? Line::RequestConfig.new(consumer) : GPIO.request_config

    config = Line::Config.new
    edge_detection ||= LineEdge::BOTH if direction.input?
    config.add_settings(offset, direction, edge_detection)
    config.output_value(LineValue::INACTIVE) if direction.output?

    request = LibGPIOD.chip_request_lines(@chip, req_config, config)
    raise "failed to obtain exclusive access to line #{offset}" unless request.null?

    req = Line::Request.new(chip, self, request, req_config, config)
    @request = req
    req
  rescue error
    @requested_by_us = false
    raise error
  end

  def release
    if (req = @request) && @requested_by_us
      @requested_by_us = false
      req.release
      @request = nil
    end
    self
  end

  def free? : Bool
    !in_use?
  end

  def request_input(consumer : String? = nil)
    release
    raise "#{self} in use by '#{self.consumer}'" unless free?
    request_exclusive_access(LineDirection::INPUT, consumer)
    self
  end

  def request_output(consumer : String? = nil)
    release
    raise "#{self} in use by '#{self.consumer}'" unless free?
    request_exclusive_access(LineDirection::OUTPUT, consumer)
    self
  end

  def requested? : Bool
    @requested_by_us && @request
  end

  def read
    result = get_request!.get_value
    raise "Reading #{self} failed" if result.error?
    result
  end

  def write(new_value : LineValue)
    raise "cannot set line to an error state" if new_value.error?
    result = get_request!.set_value(new_value)
    raise "Writing #{self} failed" if result.error?
    result
  end

  def set_high
    write(LineValue::ACTIVE)
  end

  def set_low
    write(LineValue::INACTIVE)
  end

  def high? : Bool
    read.active?
  end

  def low? : Bool
    read.active?
  end

  def set_active
    set_high
  end

  def set_inactive
    set_low
  end

  def active?
    high?
  end

  def inactive?
    low?
  end

  def on_input_change(consumer : String? = nil, &block : EdgeEventType ->)
    release
    raise "#{self} in use by '#{self.consumer}'" unless free?
    request_input(consumer)
    get_request!.watch_events(&block)
  ensure
    release
  end
end

require "./line/*"
