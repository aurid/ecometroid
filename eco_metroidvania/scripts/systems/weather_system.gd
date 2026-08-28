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

@onready var rain_particles: GPUParticles2D = $RainParticles
@onready var fog_texture: ColorRect = $FogTexture
@onready var lightning_timer: Timer = $LightningTimer

func _ready() -> void:
	weather_timer = clear_duration
	
	if rain_particles:
		rain_particles.emitting = false
	
	if fog_texture:
		fog_texture.visible = false
	
	if lightning_timer:
		lightning_timer.timeout.connect(_on_lightning_timeout)

func _process(delta: float) -> void:
	weather_timer -= delta
	
	# Transition weather
	if weather_timer <= 0:
		_change_weather()
	
	# Smooth intensity transition
	if intensity != target_intensity:
		intensity = move_toward(intensity, target_intensity, delta * 0.5)
		intensity_changed.emit(intensity)
		
		_update_visuals()

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
	_update_visuals()

func _update_visuals() -> void:
	match current_weather:
		WeatherType.CLEAR:
			if rain_particles:
				rain_particles.emitting = false
			if fog_texture:
				fog_texture.visible = false
		
		WeatherType.RAIN:
			if rain_particles:
				rain_particles.emitting = true
				rain_particles.amount = int(500 * intensity)
			if fog_texture:
				fog_texture.visible = false
		
		WeatherType.STORM:
			if rain_particles:
				rain_particles.emitting = true
				rain_particles.amount = int(800 * intensity)
			if fog_texture:
				fog_texture.visible = false
			if lightning_timer and not lightning_timer.is_running():
				lightning_timer.start(randf_range(3.0, 8.0))
		
		WeatherType.FOG:
			if rain_particles:
				rain_particles.emitting = false
			if fog_texture:
				fog_texture.visible = true
				fog_texture.color = Color(0.7, 0.7, 0.7, intensity * 0.5)

func _on_lightning_timeout() -> void:
	# Flash effect for lightning
	if fog_texture:
		fog_texture.color = Color(1.0, 1.0, 1.0, 0.8)
		await get_tree().create_timer(0.1).timeout
		fog_texture.color = Color(0.7, 0.7, 0.7, intensity * 0.5)

func get_weather_modifier() -> float:
	# Returns a modifier for creature behavior based on weather
	match current_weather:
		WeatherType.CLEAR:
			return 1.0
		WeatherType.RAIN:
			return 0.8  # Creatures slow down slightly
		WeatherType.STORM:
			return 0.5  # Creatures seek shelter
		WeatherType.FOG:
			return 0.9  # Reduced visibility
	return 1.0

func is_hazardous() -> bool:
	return current_weather == WeatherType.STORM
