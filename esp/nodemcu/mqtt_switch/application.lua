-- file : application.lua
local module = {}
m = nil

-- Sends a simple ping to the broker
--local function send_ping()
--  print("Sending ping with ID: " .. config.ID)
--  m:publish(config.ENDPOINT .. "/" .. "ping","id=" .. config.ID,0,0)
--end

local function send_state(state)
  print("Sending state: " .. state)
  m:publish(config.ENDPOINT.."/" .. config.ID.."/state", state, 0,0)
end

-- Sends my id to the broker for registration
local function register_myself()
  dataEndpoint = config.ENDPOINT .. "/" .. config.ID
  m:subscribe(dataEndpoint, 0, function(conn)
	print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
  print("Successfully subscribed to data endpoint: " .. dataEndpoint)
	print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
  end)
end

local function gpio_setting()
  gpio.mode(config.GPIO2, gpio.OUTPUT)
  gpio.mode(config.GPIO0, gpio.INPUT, gpio.PULLUP)
end

local function mqtt_start()
  m = mqtt.Client(config.ID, 120)
  -- register message callback beforehand
  m:on("message", function(conn, topic, data)
    print("Meesage received :" .. data)
    newState = tonumber(data)
    if newState and (newState == 0 or newState == 1) then
      gpio.write(config.GPIO2, newState)
      send_state(newState)
    else 
      print("Invalid command: " .. data)
    end
  end)
  -- Connect to broker
  print("Connecting to HOST: " .. config.HOST .. " PORT: " .. config.PORT)
  m:connect(config.HOST, config.PORT, 0, 1,
    function(con)
      register_myself()
      -- And then pings each 1000 milliseconds
--      tmr.stop(6)
--      tmr.alarm(6, 1000, 1, send_ping)
    end, 
    function(client, reason) 
      print("failed reason: "..reason) 
    end)
end

function module.start()
  gpio_setting()
  mqtt_start()
end

return module 