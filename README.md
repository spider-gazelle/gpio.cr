# gpio

bindings for linux gpiod, a user space interface for general purpose IO control

## Installation

ensure the development dependencies are installed: `sudo apt install libgpiod-dev`

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     gpio:
       github: spider-gazelle/gpio.cr
   ```

2. Run `shards install`

## Usage

You can list the various chips available on a system by running `gpioinfo` this will list chips and IO line details.

```crystal
require "gpio"

GPIO.default_consumer = "my app"
all_chips = GPIO::Chip.all

# or if you know the name
chip = GPIO::Chip.new "gpiochip0"
chip.lines

# take control of a line and set it's state
line = chip.line(5)
line.name
line.request_output
line.set_high
line.high? # => true
sleep 0.5
line.set_low
line.high? # => false

# release the line once finished using
# this will also happen on garbage collection
line.release
```

You can also configure the line for input and wait for input events to occur

```crystal

require "gpio"
GPIO.default_consumer = "my app"

chip = GPIO::Chip.new "gpiochip0"
line = chip.line 0

# blocks here until this line is released
# so you might want to do this in a spawn etc
line.on_input_change do |input_is|
  case input_is
  in .rising?
    puts "input is high"
  in .falling?
    puts "input is low"
  end
end

```
