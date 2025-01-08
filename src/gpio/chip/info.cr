class GPIO::Chip::Info
  def initialize(@info : LibGPIOD::ChipInfo)
  end

  def to_unsafe
    @info
  end

  def finalize
    LibGPIOD.chip_info_free @info
  end

  getter name : String do
    String.new(LibGPIOD.chip_info_get_name(@info))
  end

  getter label : String do
    String.new(LibGPIOD.chip_info_get_label(@info))
  end

  def num_lines
    LibGPIOD.chip_info_get_num_lines(@info)
  end
end
