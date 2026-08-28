extends CanvasLayer

class_name GameUI

@onready var energy_bar: TextureProgressBar = $EnergyBar
@onready var energy_label: Label = $EnergyLabel
@onready var population_label: Label = $PopulationLabel
@onready var weather_label: Label = $WeatherLabel
@onready var ecosystem_label: Label = $EcosystemLabel
@onready var message_label: Label = $MessageLabel

var player: Player = null
var ecosystem_manager: EcosystemManager = null
var weather_system: WeatherSystem = null

func _ready() -> void:
	# Find main systems in the scene
	player = get_tree().get_first_node_in_group("player")
	ecosystem_manager = get_tree().get_first_node_in_group("ecosystem")
	weather_system = get_tree().get_first_node_in_group("weather")
	
	if player:
		player.energy_changed.connect(_on_player_energy_changed)
		player.died.connect(_on_player_died)
	
	if ecosystem_manager:
		ecosystem_manager.population_changed.connect(_on_population_changed)
		ecosystem_manager.ecosystem_status_changed.connect(_on_ecosystem_status_changed)
	
	if weather_system:
		weather_system.weather_changed.connect(_on_weather_changed)
	
	_update_ui()

func _update_ui() -> void:
	if player and energy_bar:
		energy_bar.value = player.energy
		energy_bar.max_value = player.max_energy
	
	if player and energy_label:
		energy_label.text = "Energy: %.0f/%.0f" % [player.energy, player.max_energy]
	
	if ecosystem_manager and population_label:
		var count = ecosystem_manager.get_creature_count()
		population_label.text = "Creatures: %d" % count
	
	if weather_system and weather_label:
		var weather_names = ["Clear", "Rain", "Storm", "Fog"]
		weather_label.text = "Weather: " + weather_names[weather_system.current_weather]
	
	if ecosystem_manager and ecosystem_label:
		var balance = ecosystem_manager.ecosystem_balance
		var status = "Balanced"
		if balance < 0.5:
			status = "Declining"
		elif balance > 1.5:
			status = "Thriving"
		ecosystem_label.text = "Ecosystem: " + status

func _on_player_energy_changed(new_energy: float) -> void:
	if energy_bar:
		energy_bar.value = new_energy
	
	if energy_label and player:
		energy_label.text = "Energy: %.0f/%.0f" % [new_energy, player.max_energy]

func _on_player_died() -> void:
	show_message("You died! The ecosystem continues...")
	# Could trigger game over or respawn logic here

func _on_population_changed(predators: int, prey: int, scavengers: int) -> void:
	if population_label:
		population_label.text = "P: %d | Y: %d | S: %d" % [predators, prey, scavengers]

func _on_ecosystem_status_changed(balance: float) -> void:
	if ecosystem_label:
		var status = "Balanced"
		if balance < 0.5:
			status = "Declining"
		elif balance > 1.5:
			status = "Thriving"
		ecosystem_label.text = "Ecosystem: " + status + " (%.2f)" % balance

func _on_weather_changed(new_weather: WeatherSystem.WeatherType) -> void:
	if weather_label:
		var weather_names = ["Clear", "Rain", "Storm", "Fog"]
		weather_label.text = "Weather: " + weather_names[new_weather]
		
		if new_weather == WeatherSystem.WeatherType.STORM:
			show_message("Warning: Storm approaching!")

func show_message(text: String) -> void:
	if message_label:
		message_label.text = text
		message_label.modulate.a = 1.0
		
		# Fade out message after 3 seconds
		var tween = create_tween()
		tween.tween_interval(3.0)
		tween.tween_property(message_label, "modulate:a", 0.0, 1.0)
