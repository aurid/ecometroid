extends Node2D

@onready var player: Player = $Player
@onready var ecosystem_manager: EcosystemManager = $EcosystemManager
@onready var weather_system: WeatherSystem = $WeatherSystem
@onready var camera: Camera2D = $Camera2D
@onready var tile_map: TileMap = $TileMap

func _ready() -> void:
	# Add systems to groups for UI access
	player.add_to_group("player")
	ecosystem_manager.add_to_group("ecosystem")
	weather_system.add_to_group("weather")
	
	# Initialize ecosystem with some creatures
	_initialize_ecosystem()
	
	# Setup camera to follow player
	if camera and player:
		camera.follow_smoothing = 5.0

func _initialize_ecosystem() -> void:
	# Spawn initial creatures
	var spawn_points = [
		Vector2(200, 300),
		Vector2(400, 300),
		Vector2(600, 300),
		Vector2(800, 300),
		Vector2(1000, 300)
	]
	
	for point in spawn_points:
		var rand = randf()
		var creature_type = Creature.CreatureType.PREY
		
		if rand < 0.2:
			creature_type = Creature.CreatureType.PREDATOR
		elif rand < 0.4:
			creature_type = Creature.CreatureType.SCAVENGER
		
		ecosystem_manager.spawn_creature(point, creature_type)
	
	# Spawn some initial food
	for i in range(5):
		var x = randf_range(100, 1100)
		var y = 350
		ecosystem_manager.spawn_food(Vector2(x, y), randf_range(15, 30))

func _process(_delta: float) -> void:
	# Update camera to follow player
	if camera and player:
		camera.global_position = player.global_position
	
	# Check for weather hazards
	if weather_system.is_hazardous() and player:
		# Storm could damage player or affect gameplay
		pass

func _input(event: InputEvent) -> void:
	# Debug: Spawn creature on right-click
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		var spawn_pos = get_global_mouse_position()
		ecosystem_manager.spawn_creature(spawn_pos)
	
	# Debug: Show ecosystem status on key press
	if event.is_action_pressed("ui_focus_next"):
		print("=== Ecosystem Status ===")
		print("Creatures: ", ecosystem_manager.get_creature_count())
		print("Food Sources: ", ecosystem_manager.get_food_count())
		print("Balance: ", ecosystem_manager.ecosystem_balance)
		print("Weather: ", WeatherSystem.WeatherType.keys()[weather_system.current_weather])
