extends Node2D

class_name WeatherSystem

enum WeatherType { CLEAR, RAIN, STORM, FOG }

@export var current_weather: WeatherType = WeatherType.CLEAR
@export var weather_duration: float = 60.0
@export var clear_duration: float = 120.0

var weather_timer: float = 0.0
var intensity: float = 0.0
var target_intensity: float = 0.0

signal weather_changed(new_weather: WeatherType)
signal intensity_changed(new_intensity: float)

func _ready() -> void:
	weather_timer = clear_duration

func _process(delta: float) -> void:
	weather_timer -= delta
	
	# Transition weather
	if weather_timer <= 0:
		_change_weather()
	
	# Smooth intensity transition
	if intensity != target_intensity:
		intensity = move_toward(intensity, target_intensity, delta * 0.5)
		intensity_changed.emit(intensity)

func _change_weather() -> void:
	var rand = randf()
	
	if rand < 0.4:
		current_weather = WeatherType.CLEAR
		weather_timer = clear_duration
		target_intensity = 0.0
	elif rand < 0.7:
		current_weather = WeatherType.RAIN
		weather_timer = weather_duration
		target_intensity = 0.6
	elif rand < 0.9:
		current_weather = WeatherType.STORM
		weather_timer = weather_duration * 0.5
		target_intensity = 1.0
	else:
		current_weather = WeatherType.FOG
		weather_timer = weather_duration * 1.5
		target_intensity = 0.4
	
	weather_changed.emit(current_weather)

func get_weather_modifier() -> float:
	match current_weather:
		WeatherType.CLEAR:
			return 1.0
		WeatherType.RAIN:
			return 0.8
		WeatherType.STORM:
			return 0.5
		WeatherType.FOG:
			return 0.9
	return 1.0

func is_hazardous() -> bool:
	return current_weather == WeatherType.STORM
