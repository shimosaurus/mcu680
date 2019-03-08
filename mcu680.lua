--------------------------------------------------------------------------------
-- GY-MCU680V1 module for NodeMCU
-- LICENCE: http://opensource.org/licenses/MIT
-- @shimosaurus, 1 Mar 2019
--------------------------------------------------------------------------------
--Use:
--require("mcu680"):init(Tx_pin, Rx_pin)
--require("mcu680"):read(function(temperature, humidity, pressure, iaq_accuracy, iaq, gas_resistance, altitude)
--    print(string.format("Temperature: %g C", temperature/100))
--    print(string.format("Humidity: %g %%", humidity/100))
--    print(string.format("Pressure: %g hPa", pressure/100))
--    print(string.format("IAQ accuracy: %g", iaq_accuracy))
--    print(string.format("IAQ: %g", iaq))
--    print(string.format("Gas resistance: %g Ohm", gas_resistance))
--    print(string.format("Altitude: %g m", altitude))
--end)
--
local modname = ...

-- Used modules and functions
local string, print, softuart, struct, bit =
      string, print, softuart, struct, bit
-- Local functions
local node_task_post, node_task_LOW_PRIORITY = node.task.post, node.task.LOW_PRIORITY
local string_char, string_format = string.char, string.format
local softuart_setup = softuart.setup
local struct_unpack = struct.unpack
local bit_band, bit_rshift = bit.band, bit.rshift

string, softuart, struct, bit = nil

local cb, suart

local function _chsum(data)
    local sum = 0
    for i = 1, 19 do
        sum = sum + data:byte(i)
    end
    return (sum % 256) == data:byte(20)
end

local function init(self, tx, rx)

    suart = softuart_setup(9600, tx, rx)
    --config commands. don't know if needed:
    suart:write(string_char(0xA5, 0x55, 0x3F, 0x39))
    suart:write(string_char(0xA5, 0x56, 0x02, 0xFD))

    local data = ""
    suart:on("data", 20, function(d)
        data = data .. d
        local i = 0
        while i <= #data do
            i = i + 1

            if #data > i and data:byte(i) == 0x5A and data:byte(i+1) == 0x5A then
                data = data:sub(i)

                if #data >= 20 and _chsum(data) then
                    local temperature = struct_unpack(">h", data:sub(5,6))
                    local humidity = struct_unpack(">h", data:sub(7,8))
                    local pressure = struct_unpack(">i3", data:sub(9,11))
                    local iaq_accuracy = bit_rshift(bit_band(data:byte(12), 0xF0), 4)
                    local iaq = struct_unpack(">h", string_char(bit_band(data:byte(12), 0x0F), data:byte(13)))
                    local gas_resistance = struct_unpack(">L", data:sub(14,17))
                    local altitude = struct_unpack(">h", data:sub(18,19))
                    data = data:sub(21)
                    i = 0
                    if cb then
                        node_task_post(node_task_LOW_PRIORITY, function() return cb(temperature, humidity, pressure, iaq_accuracy, iaq, gas_resistance, altitude) end)
                        node_task_post(node_task_LOW_PRIORITY, function() cb = nil end)
                    end
                end
            end
        end
    end, 0)
end

local function read(self, lcb)
    cb = lcb
end

-- Set module name as parameter of require and return module table
local M = {
    read = read, init = init
}
_G[modname or 'mcu680'] = M
return M
