#!/usr/bin/env ruby
require 'bundler/setup'
require 'tempodb'
require 'dino'
require 'time'
require 'yaml'

include TempoDB
include Dino

def log(message)
	puts "#{Time.new} - #{message}"
end

#TempoDB API setup
config_file = File.expand_path(File.join(File.dirname(__FILE__), 'config.yml'))
config = YAML.load_file(config_file)
client = Client.new config[:tempodb][:key], config[:tempodb][:secret]

#Dino Arduino setup
board = Board.new(TxRx::Serial.new)
sensor = Components::Sensor.new(pin: 'A0', board: board)
window_led = Components::Led.new(pin: 13, board: board)

#send readings every T seconds
T = config[:readings][:interval]
puts T


#Average readings over window_size seconds
window_size = config[:readings][:window] 
puts window_size

start_time = Time.new
last_time = Time.new - T
last_reading = nil 

window_open = false 
window = []
window_start = nil

log "Starting"
sensor.when_data_received do |raw|
  now = Time.new
  
  if now - last_time < (T - window_size)
    #Not ready to start the window  
    next
  elsif window_open 
    #The window is open - log readings and check for closing
    #Reject bizarre negative outliers
    raw = raw.to_f
    window << raw if raw > 0

    if now - window_start >= window_size
      #The window is finished
      sum = window.inject(:+)
      mean = sum / window.size

      volts = (mean / 1024.0) * 5.0
      degrees = (volts - 0.5) * 100
 
      datum = DataPoint.new(now.utc, degrees.round(4))
      client.write_key(config[:tempodb][:series], [datum])
      	
			if config[:log]
				log "Send #{degrees.round(3)}"
			end

      last_time = now
      last_reading = degrees

      window_open = false
      window_led.send :off
    end
  else
    #Open the window
    window_open = true
    window_start = now
    window_led.send :on
  end
end

#Sleep the main thread indefinitely whilst Dino works in the background
sleep
