# https://libgpiod.readthedocs.io/en/latest/core_api.html
module GPIO
  @[Link("gpiod")]
  lib LibGPIOD
    type Chip = Void*
    type ChipInfo = Void*
    type LineInfo = Void*
    type EdgeEvent = Void*
    type LineConfig = Void*
    type LineRequest = Void*
    type LineSettings = Void*
    type RequestConfig = Void*
    type EdgeEventBuffer = Void*

    fun version_string = gpiod_api_version : LibC::Char*
    fun is_gpiochip_device = gpiod_is_gpiochip_device(path : LibC::Char*) : Bool

    enum LineDirection
      AS_IS
      INPUT
      OUTPUT
    end

    enum LineEdge
      NONE
      RISING
      FALLING
      BOTH
    end

    enum LineValue
      ERROR
      INACTIVE
      ACTIVE
    end

    enum EdgeEventType
      RISING
      FALLING
    end

    # Grabs a reference to a GPIO chip
    # returns GPIO chip handle or NULL if an error occurred.
    fun chip_open = gpiod_chip_open(path : LibC::Char*) : Chip
    fun chip_close = gpiod_chip_close(chip : Chip)
    fun chip_get_fd = gpiod_chip_get_fd(chip : Chip) : LibC::Int

    # Chip information
    fun chip_get_info = gpiod_chip_get_info(chip : Chip) : ChipInfo
    fun chip_info_free = gpiod_chip_info_free(info : ChipInfo)
    fun chip_info_get_name = gpiod_chip_info_get_name(info : ChipInfo) : LibC::Char*
    fun chip_info_get_label = gpiod_chip_info_get_label(info : ChipInfo) : LibC::Char*
    fun chip_info_get_num_lines = gpiod_chip_info_get_num_lines(info : ChipInfo) : LibC::SizeT

    # Line information
    fun chip_get_line_info = gpiod_chip_get_line_info(chip : Chip, offset : LibC::UInt) : LineInfo
    fun line_info_copy = gpiod_line_info_copy(info : LineInfo) : LineInfo
    fun line_info_free = gpiod_line_info_free(info : LineInfo)
    fun line_info_get_name = gpiod_line_info_get_name(info : LineInfo) : LibC::Char*
    fun line_info_is_used = gpiod_line_info_is_used(info : LineInfo) : Bool
    fun line_info_get_consumer = gpiod_line_info_get_consumer(info : LineInfo) : LibC::Char*
    fun line_info_get_direction = gpiod_line_info_get_direction(info : LineInfo) : LineDirection
    fun line_info_get_edge_detection = gpiod_line_info_get_edge_detection(info : LineInfo) : LineEdge

    # Request config
    fun request_config_new = gpiod_request_config_new : RequestConfig
    fun request_config_free = gpiod_request_config_free(config : RequestConfig)
    fun request_config_set_consumer = gpiod_request_config_set_consumer(config : RequestConfig, consumer : LibC::Char*)

    # Line settings
    fun line_settings_new = gpiod_line_settings_new : LineSettings
    fun line_settings_free = gpiod_line_settings_free(settings : LineSettings)
    fun line_settings_reset = gpiod_line_settings_reset(settings : LineSettings)
    fun line_settings_set_direction = gpiod_line_settings_set_direction(settings : LineSettings, direction : LineDirection) : LibC::Int # 0 on success, -1 on error
    fun line_settings_set_edge_detection = gpiod_line_settings_set_edge_detection(settings : LineSettings, edge : LineEdge) : LibC::Int # 0 on success, -1 on error

    # Line config
    fun line_config_new = gpiod_line_config_new : LineConfig
    fun line_config_free = gpiod_line_config_free(config : LineConfig)
    fun line_config_reset = gpiod_line_config_reset(config : LineConfig)
    fun line_config_add_line_settings = gpiod_line_config_add_line_settings(config : LineConfig, offsets : LibC::UInt*, num_offsets : LibC::SizeT, settings : LineSettings) : LibC::Int
    fun line_config_set_output_values = gpiod_line_config_set_output_values(config : LineConfig, values : LineValue*, num_values : LibC::SizeT) : LibC::Int

    # Line request control
    # Lines must have edge detection set for edge events to be emitted. By default edge detection is disabled.
    fun chip_request_lines = gpiod_chip_request_lines(chip : Chip, config : RequestConfig, lines : LineConfig) : LineRequest
    fun line_request_release = gpiod_line_request_release(request : LineRequest)
    fun line_request_set_value = gpiod_line_request_set_value(request : LineRequest, offset : LibC::UInt, value : LineValue) : LibC::Int
    fun line_request_set_values = gpiod_line_request_set_values(request : LineRequest, value : LineValue*) : LibC::Int
    fun line_request_get_value = gpiod_line_request_get_value(request : LineRequest, offset : LibC::UInt) : LineValue
    fun line_request_get_fd = gpiod_line_request_get_fd(request : LineRequest) : LibC::Int
    fun line_request_read_edge_events = gpiod_line_request_read_edge_events(request : LineRequest, buffer : EdgeEventBuffer, max_events : LibC::SizeT) : LibC::Int

    # edge events
    fun edge_event_free = gpiod_edge_event_free(event : EdgeEvent)
    fun edge_event_copy = gpiod_edge_event_copy(event : EdgeEvent) : EdgeEvent
    fun edge_event_get_event_type = gpiod_edge_event_get_event_type(event : EdgeEvent) : EdgeEventType
    fun edge_event_get_line_offset = gpiod_edge_event_get_line_offset(event : EdgeEvent) : LibC::UInt

    fun edge_event_buffer_new = gpiod_edge_event_buffer_new(capacity : LibC::SizeT) : EdgeEventBuffer
    fun edge_event_buffer_free = gpiod_edge_event_buffer_free(buffer : EdgeEventBuffer)
    fun edge_event_buffer_get_event = gpiod_edge_event_buffer_get_event(buffer : EdgeEventBuffer, index : LibC::ULong) : EdgeEvent # NOTE:: must copy before use
  end
end
