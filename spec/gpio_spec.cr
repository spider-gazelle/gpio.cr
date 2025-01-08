require "./spec_helper"

describe GPIO do
  it "should open all GPIO devices" do
    chips = GPIO::Chip.all
    chips.each do |chip|
      puts chip.name
    end

    if chip = chips.first?
      line = chip.line(0)

      spawn do
        sleep 2.seconds
        line.release
      end

      line.on_input_change do |input_is|
        case input_is
        in .rising?
          puts "input is high"
        in .falling?
          puts "input is low"
        end
      end
    end
  end
end
