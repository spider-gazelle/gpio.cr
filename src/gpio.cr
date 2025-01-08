require "./gpio/lib_gpiod"

# bindings for linux lib general purpose IO
module GPIO
  {% begin %}
    VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify.downcase }}
  {% end %}

  alias LineDirection = LibGPIOD::LineDirection
  alias LineEdge = LibGPIOD::LineEdge
  alias LineValue = LibGPIOD::LineValue
  alias EdgeEventType = LibGPIOD::EdgeEventType

  class_getter lib_version : String do
    String.new(LibGPIOD.version_string)
  end

  class_property default_consumer : String = "gpio.cr"

  def self.default_consumer=(value : String)
    @@request_config = nil
    @@default_consumer = value
  end

  class_getter request_config : Line::RequestConfig do
    cfg = Line::RequestConfig.new
    cfg.consumer = @@default_consumer
    cfg
  end
end

require "./gpio/*"
