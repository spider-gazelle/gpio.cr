class GPIO::Chip
  def self.all
    Dir.glob("/dev/gpiochip*").sort!.map { |path| new(Path[path]) }
  end

  def initialize(path : Path)
    @chip = LibGPIOD.chip_open(path.to_s)
    raise "failed to open chip @ #{path}" if @chip.null?
  end

  def initialize(name : String)
    @chip = LibGPIOD.chip_open_by_name(name)
    raise "failed to open chip: #{name}" if @chip.null?
  end

  @chip : LibGPIOD::Chip*

  def to_unsafe
    @chip
  end

  def finalize
    LibGPIOD.chip_close @chip
  end

  def to_s(io : IO)
    io << "gpio: "
    io << name
  end

  getter name : String do
    String.new(@chip.value.name.to_unsafe)
  end

  getter label : String do
    String.new(@chip.value.label.to_unsafe)
  end

  def num_lines
    @chip.value.num_lines
  end

  def line(idx : Int32)
    Line.new self, idx
  end
end
