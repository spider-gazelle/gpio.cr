class GPIO::Chip
  class Ref
    def initialize(@to_unsafe : LibGPIOD::Chip)
    end

    getter to_unsafe : LibGPIOD::Chip

    def finalize
      LibGPIOD.chip_close @to_unsafe
    end
  end

  def self.all
    Dir.glob("/dev/gpiochip*").sort!.map { |path| new(Path[path]) }
  end

  def initialize(@path : Path)
    chip = LibGPIOD.chip_open(@path.to_s)
    raise "failed to open chip @ #{@path}" if chip.null?
    @ref = Ref.new(chip)
  end

  def self.new(name : String)
    new Path["/dev", name]
  end

  getter path : Path

  def to_unsafe
    @ref.to_unsafe
  end

  def to_s(io : IO)
    io << "gpio: "
    io << name
  end

  getter chip_info : Chip::Info do
    Chip::Info.new(LibGPIOD.chip_get_info(self))
  end

  def name
    chip_info.name
  end

  def label
    chip_info.label
  end

  def num_lines
    chip_info.num_lines
  end

  def file_descriptor
    IO::FileDescriptor.new(LibGPIOD.chip_get_fd(self), close_on_finalize: false)
  end

  def line(idx : Int32)
    Line.new self, idx
  end
end

require "./chip/*"
