# MCU680 Module for NodeMCU
| Since  | Origin / Contributor  | Maintainer  | Source  |
| :----- | :-------------------- | :---------- | :------ |
| 2019-03-01 | [Jan Simsa](https://github.com/shimosaurus) | [Jan Simsa](https://github.com/shimosaurus) | [mcu680.lua](https://github.com/shimosaurus/mcu680/blob/master/mcu680.lua) |

This Lua code for NodeMCU provides access to module GY-MCU680V1 with sensor [BME680](https://www.bosch-sensortec.com/bst/products/all_products/bme680) and MCU STM32 obtain temperature, humidity, atmospheric pressure, IAQ (indoor air quality) and resistance value. Data read is through serial port.

!!! note
    The module requires `softuart`, `struct` and `bit` C module built into firmware.

### Require
```lua
mcu680 = require("mcu680")
```

### Release
```lua
mcu680 = nil
package.loaded["mcu680"] = nil
```

## mcu680:init()
Initializes UART port.

#### Syntax
`mcu680.init(tx, rx)`

#### Parameters
- `tx` UART Tx pin number.
- `rx` UART Rx pin number.

#### Returns
`nil`

## mcu680:read()
Reads values from the module. Module send output every 3 seconds, the callback is executed once after first message received.

#### Syntax
`mcu680:read(callback)`

#### Parameters
- `callback` function that receives all results when all conversions finish

#### Callback function parameters
- `temperature` temperature in Celsius multiplied by 100
- `humidity` relative humidity in percent multiplied by 100
- `pressure` air pressure in hectopascals multiplied by 100
- `iaq_accuracy` The accuracy status is equal to zero during the power-on stabilization times of the sensor and is equal to 3 when the sensor achieves best performance
- `iaq` indoor air quality index
- `gas_resistance` gas resistance in Ohms
- `altitude`

Indoor air quality (IAQ) classification is described in [BME680 datasheet](https://ae-bst.resource.bosch.com/media/_tech/media/datasheets/BST-BME680-DS001.pdf) on page 9, Table 4

| IAQ Index | Air Quality |
|:---------:|:-----------:|
| 0 – 50 | good |
| 51 – 100 | average |
| 101 – 150 | little bad |
| 151 – 200 | bad |
| 201 – 300 | worse |
| 301 – 500 | very bad |

#### Returns
`nil`

#### Example
```lua
mcu680 = require("mcu680")
tx, rx = 1, 2
mcu680:init(tx, rx)
mcu680:read(function(temperature, humidity, pressure, iaq_accuracy, iaq, gas_resistance, altitude)
    print(string.format("Temperature: %g C", temperature/100))
    print(string.format("Humidity: %g %%", humidity/100))
    print(string.format("Pressure: %g hPa", pressure/100))
    print(string.format("IAQ accuracy: %g", iaq_accuracy))
    print(string.format("IAQ: %g", iaq))
    print(string.format("Gas resistance: %g Ohm", gas_resistance))
    print(string.format("Altitude: %g m", altitude))
end)
```
