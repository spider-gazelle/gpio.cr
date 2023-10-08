# bindings for linux lib general purpose IO
module GPIO
  {% begin %}
    VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify.downcase }}
  {% end %}

  class_getter lib_version : String do
    String.new(LibGPIOD.version_string)
  end

  class_property default_consumer : String = "gpio.cr"
end

require "./gpio/*"
