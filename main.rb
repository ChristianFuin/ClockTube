require 'time'
require 'test/unit'
require 'net/http'
require 'json'
require 'ostruct'

#Controls the flow of the API to get accurate weather
class APIWeather
	@@api_key = "c59a9a04e86c9b953c60abbe208d17a0"
	@@url = "http://api.openweathermap.org/data/2.5/weather?q={city}&units=metric&appid={key}"

	#Creates the URL to a request according to the city parameter (Parameter can be followed by the country symbol, E.G.: "london,uk")
	def get_url_request(city)
		url = @@url.gsub('{city}',city).gsub('{key}', @@api_key)
	end

	#Sends the request to the WebService and receives the response with the accurate weather
	def send_request(city)
		Net::HTTP.get(URI(get_url_request(city)))
	end

	#Return a new Weather object
	def build_weather(city)
		json = JSON.parse(APIWeather.new.send_request(city), object_class:OpenStruct)
		Weather.new(json.main.temp,json.main.temp_min,json.main.temp_max,json.weather[0].description,json.weather[0].main,json.rain)
	end
end

class Weather

	def initialize(temp,min,max,description,main,rain = false)
		@temp = temp.to_i
		@min = min.to_i
		@max = max.to_i
		@description = description
		@main = main
		@rain = rain
	end

	def get_temp
		"#{@temp}°"
	end

	def get_temp_min
		"#{@min}°"
	end

	def get_temp_max
		"#{@max}°"
	end

	def weather_like?
		@description
	end


	#Returns the weather's condition
	def condition

		case

			when @temp > 5 && @temp <= 12
				"cold"

			when @temp <= 5
				"heavy_cold"

			when @rain
				"rainy"	

			when @main.downcase == "clear"
				"sunny"	

			else
				"mild"
		end		  	

 	end

 	#If it's rainning returns an warn to the user to carry an umbrella
	def umbrella?
		@rain ? "You should carry an umbrella" : false
	end

	#Displays the Weather to the user
	def display
		puts "|Temp: #{@temp} | Min : #{@min} | Max: #{@max}| "
		puts "Weather now is : #{@description}"
		puts umbrella? if @rain
	end
end


#Open a file, read every single line and add them into an array, returning it. If an error occurs it will print the error 
def get_youtube_videos(file)
	begin
		file_open = File.open(file, "r")
		if file_open then return file_open.read() end
	rescue Exception => e
		puts "An error has occurred : #{e.message}"	
	end
end

#Transforms the JSON file into an object and returns it, if something goes wrong if the file it throws and error 
def videos_json(file)
	begin
		JSON.parse(get_youtube_videos(file), object_class:OpenStruct)
	rescue Exception => e
		if e.inspect.include? "751" then puts "The JSON object seems to be wrong" else puts e.message end
	end	
end

#Picks a song according to the weather 
def pick_video(videos, weather)
	videos[weather].url
end

#when the alarm set is to go off it will open an youtube video playing the music to wake up the person
def go_off(url)
	system("start chrome.exe #{url}")
end

#Set aside a time that the system will do nothing but wait to execute the next command
def put_sleep(time)
	sleep(time)
end

#Calculates how many minutes till the next alarm 
def time_difference(time, current_time = Time.now)
	time - current_time
end

#Gets the alarm's time from the user
def set_alarm
	print "Set an alarm : "
	alarm = Time.parse(gets.chomp)
end

#Displays the next alarm
def next_alarm(alarm)
	puts "Next alarm is set to : #{alarm}"
end

###----------- main application -----------------

weather = APIWeather.new.build_weather("london,uk")
weather.display

alarm = set_alarm
next_alarm(alarm)

put_sleep(time_difference(alarm))
go_off(pick_video(videos_json("videos.json"),weather.condition))


exit

