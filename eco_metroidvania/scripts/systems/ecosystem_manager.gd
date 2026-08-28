extends Node

class_name EcosystemManager

@export var max_creatures: int = 20
@export var predator_spawn_chance: float = 0.3
@export var prey_spawn_chance: float = 0.5
@export var scavenger_spawn_chance: float = 0.2

var creatures: Array = []
var food_sources: Array = []
var ecosystem_balance: float = 1.0  # 1.0 = balanced, <1 = declining, >1 = thriving

signal population_changed(predators: int, prey: int, scavengers: int)
signal ecosystem_status_changed(balance: float)

@onready var creature_container: Node = $CreatureContainer
@onready var food_container: Node = $FoodContainer

func _ready() -> void:
	if not creature_container:
		creature_container = Node.new()
		creature_container.name = "CreatureContainer"
		add_child(creature_container)
	
	if not food_container:
		food_container = Node.new()
		food_container.name = "FoodContainer"
		add_child(food_container)

func _process(_delta: float) -> void:
	_update_ecosystem_balance()

func spawn_creature(position: Vector2, force_type: Creature.CreatureType = -1) -> Creature:
	if creatures.size() >= max_creatures:
		return null
	
	var creature_scene = preload("res://scenes/creatures/creature.tscn")
	if not ResourceLoader.exists("res://scenes/creatures/creature.tscn"):
		# Create creature programmatically if scene doesn't exist
		return _create_creature_programmatic(position, force_type)
	
	var creature = creature_scene.instantiate()
	creature.global_position = position
	
	if force_type != -1:
		creature.creature_type = force_type
	else:
		# Random type based on probabilities
		var rand = randf()
		if rand < predator_spawn_chance:
			creature.creature_type = Creature.CreatureType.PREDATOR
		elif rand < predator_spawn_chance + prey_spawn_chance:
			creature.creature_type = Creature.CreatureType.PREY
		else:
			creature.creature_type = Creature.CreatureType.SCAVENGER
	
	creature.died.connect(_on_creature_died.bind(creature))
	creature_container.add_child(creature)
	creatures.append(creature)
	
	_emit_population_signal()
	return creature

func _create_creature_programmatic(position: Vector2, force_type: int) -> Creature:
	var creature = Creature.new()
	creature.global_position = position
	
	if force_type != -1:
		creature.creature_type = force_type
	else:
		var rand = randf()
		if rand < predator_spawn_chance:
			creature.creature_type = Creature.CreatureType.PREDATOR
		elif rand < predator_spawn_chance + prey_spawn_chance:
			creature.creature_type = Creature.CreatureType.PREY
		else:
			creature.creature_type = Creature.CreatureType.SCAVENGER
	
	creature.died.connect(_on_creature_died.bind(creature))
	creature_container.add_child(creature)
	creatures.append(creature)
	
	_emit_population_signal()
	return creature

func spawn_food(position: Vector2, energy_value: float = 25.0) -> Food:
	var food_scene = preload("res://scenes/environment/food.tscn")
	var food: Food
	
	if ResourceLoader.exists("res://scenes/environment/food.tscn"):
		food = food_scene.instantiate()
	else:
		food = Food.new()
	
	food.energy_value = energy_value
	food.global_position = position
	food_container.add_child(food)
	food_sources.append(food)
	
	food.decayed_completely.connect(_on_food_decayed.bind(food))
	return food

func _on_creature_died(creature: Creature) -> void:
	creatures.erase(creature)
	_emit_population_signal()
	
	# Spawn food where creature died
	spawn_food(creature.global_position, creature.current_energy * 0.5)

func _on_food_decayed(food: Food) -> void:
	food_sources.erase(food)

func _update_ecosystem_balance() -> void:
	var predators = 0
	var prey = 0
	var scavengers = 0
	
	for creature in creatures:
		if not is_instance_valid(creature):
			continue
		
		match creature.creature_type:
			Creature.CreatureType.PREDATOR:
				predators += 1
			Creature.CreatureType.PREY:
				prey += 1
			Creature.CreatureType.SCAVENGER:
				scavengers += 1
	
	# Calculate balance based on predator/prey ratio
	if prey > 0:
		ecosystem_balance = float(predators) / float(prey)
		ecosystem_balance = clamp(ecosystem_balance, 0.0, 2.0)
	else:
		ecosystem_balance = 0.0
	
	ecosystem_status_changed.emit(ecosystem_balance)

func _emit_population_signal() -> void:
	var predators = 0
	var prey = 0
	var scavengers = 0
	
	for creature in creatures:
		if not is_instance_valid(creature):
			continue
		
		match creature.creature_type:
			Creature.CreatureType.PREDATOR:
				predators += 1
			Creature.CreatureType.PREY:
				prey += 1
			Creature.CreatureType.SCAVENGER:
				scavengers += 1
	
	population_changed.emit(predators, prey, scavengers)

func get_creature_count() -> int:
	return creatures.size()

func get_food_count() -> int:
	return food_sources.size()

func clear_all() -> void:
	for creature in creatures:
		if is_instance_valid(creature):
			creature.queue_free()
	creatures.clear()
	
	for food in food_sources:
		if is_instance_valid(food):
			food.queue_free()
	food_sources.clear()
