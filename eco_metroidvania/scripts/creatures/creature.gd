extends CharacterBody2D

class_name Creature

enum CreatureType { PREDATOR, PREY, SCAVENGER }
enum BehaviorState { IDLE, WANDER, HUNT, FLEE, EAT, REST }

@export var creature_type: CreatureType = CreatureType.PREY
@export var max_energy: float = 100.0
@export var move_speed: float = 150.0
@export var detection_range: float = 200.0
@export var energy_drain_rate: float = 2.0
@export var eat_rate: float = 20.0

var current_energy: float
var current_state: BehaviorState = BehaviorState.IDLE
var target: Node2D = null
var wander_direction: Vector2 = Vector2.RIGHT
var state_timer: float = 0.0

signal died
signal energy_changed(new_energy: float)

func _ready() -> void:
	current_energy = max_energy
	
	# Setup detection area if it exists
	var detection_area = get_node_or_null("DetectionArea")
	if detection_area:
		detection_area.body_entered.connect(_on_body_entered)
		detection_area.body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	# Drain energy over time
	current_energy -= energy_drain_rate * delta
	energy_changed.emit(current_energy)
	
	if current_energy <= 0:
		die()
		return
	
	# State machine
	_update_state(delta)
	_apply_behavior(delta)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	move_and_slide()

func _update_state(delta: float) -> void:
	state_timer -= delta
	
	match current_state:
		BehaviorState.IDLE:
			if state_timer <= 0:
				_change_state(BehaviorState.WANDER)
		
		BehaviorState.WANDER:
			if target:
				if creature_type == CreatureType.PREDATOR:
					_change_state(BehaviorState.HUNT)
				elif creature_type == CreatureType.PREY:
					_change_state(BehaviorState.FLEE)
			elif state_timer <= 0:
				_change_state(BehaviorState.IDLE)
		
		BehaviorState.HUNT:
			if not target or not is_instance_valid(target):
				_change_state(BehaviorState.WANDER)
			elif state_timer <= 0:
				_change_state(BehaviorState.WANDER)
		
		BehaviorState.FLEE:
			if not target or not is_instance_valid(target):
				_change_state(BehaviorState.WANDER)
			elif state_timer <= 0:
				_change_state(BehaviorState.WANDER)
		
		BehaviorState.EAT:
			if state_timer <= 0 or current_energy >= max_energy:
				_change_state(BehaviorState.IDLE)
		
		BehaviorState.REST:
			if state_timer <= 0:
				_change_state(BehaviorState.IDLE)

func _change_state(new_state: BehaviorState) -> void:
	current_state = new_state
	state_timer = randf_range(2.0, 5.0)

func _apply_behavior(delta: float) -> void:
	match current_state:
		BehaviorState.IDLE:
			velocity.x = move_toward(velocity.x, 0, move_speed * 0.3)
		
		BehaviorState.WANDER:
			if state_timer <= 1.0:
				wander_direction = Vector2(randf_range(-1, 1), 0).normalized()
			
			velocity.x = wander_direction.x * move_speed * 0.5
			
			var sprite = get_node_or_null("Sprite2D")
			if sprite:
				sprite.flip_h = wander_direction.x < 0
		
		BehaviorState.HUNT:
			if target and is_instance_valid(target):
				var direction = (target.global_position - global_position).normalized()
				velocity.x = direction.x * move_speed
				
				var sprite = get_node_or_null("Sprite2D")
				if sprite:
					sprite.flip_h = direction.x < 0
				
				# Try to eat if close enough
				if global_position.distance_to(target.global_position) < 30:
					_eat_target()
		
		BehaviorState.FLEE:
			if target and is_instance_valid(target):
				var direction = (global_position - target.global_position).normalized()
				velocity.x = direction.x * move_speed * 1.2
				
				var sprite = get_node_or_null("Sprite2D")
				if sprite:
					sprite.flip_h = direction.x < 0
		
		BehaviorState.EAT:
			velocity.x = move_toward(velocity.x, 0, move_speed * 0.5)
		
		BehaviorState.REST:
			velocity.x = move_toward(velocity.x, 0, move_speed * 0.5)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if creature_type == CreatureType.PREDATOR:
			target = body
		elif creature_type == CreatureType.PREY:
			target = body
	elif body is Creature:
		if creature_type == CreatureType.PREDATOR and body.creature_type == CreatureType.PREY:
			target = body
		elif creature_type == CreatureType.PREY and body.creature_type == CreatureType.PREDATOR:
			target = body
		elif creature_type == CreatureType.SCAVENGER and body.current_energy < 10:
			target = body

func _on_body_exited(body: Node2D) -> void:
	if body == target:
		target = null

func _eat_target() -> void:
	if target and is_instance_valid(target):
		if target is Creature:
			target.die()
			current_energy = min(current_energy + eat_rate, max_energy)
			energy_changed.emit(current_energy)
			_change_state(BehaviorState.EAT)
		elif target is Player:
			target.take_damage(10.0)
			_change_state(BehaviorState.EAT)

func die() -> void:
	died.emit()
	# Spawn food where creature died
	_spawn_food()
	queue_free()

func _spawn_food() -> void:
	var food = Food.new()
	food.energy_value = current_energy * 0.5
	get_tree().current_scene.add_child(food)
	food.global_position = global_position

func set_resting() -> void:
	_change_state(BehaviorState.REST)
	current_energy += 5.0
	energy_changed.emit(current_energy)
