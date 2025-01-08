class GPIO::Line::RequestConfig
  def initialize(consumer : String? = nil)
    @to_unsafe = LibGPIOD.request_config_new
    raise "failed to create request config" if @to_unsafe.null?
    self.consumer = consumer if consumer.presence
  end

  getter to_unsafe : LibGPIOD::RequestConfig

  def finalize
    LibGPIOD.request_config_free @to_unsafe
  end

  property consumer : String? = nil

  def consumer=(value : String?)
    LibGPIOD.request_config_set_consumer(self, value.nil? ? "" : value)
    @consumer = value
  end
end
