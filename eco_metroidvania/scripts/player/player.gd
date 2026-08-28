extends CharacterBody2D

class_name Player

@export var speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0

var can_dash: bool = true
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Energy system (Rain World inspired)
var energy: float = 100.0
var max_energy: float = 100.0
var energy_drain_rate: float = 10.0
var energy_regen_rate: float = 5.0

signal energy_changed(new_energy: float)
signal died

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# Handle dash cooldown
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	
	# Handle dash duration
	if is_dashing:
		dash_timer -= delta
		energy -= energy_drain_rate * delta
		energy_changed.emit(energy)
		
		if dash_timer <= 0 or energy <= 0:
			is_dashing = false
			can_dash = false
	
	# Regenerate energy when not dashing
	if not is_dashing and energy < max_energy:
		energy = min(energy + energy_regen_rate * delta, max_energy)
		energy_changed.emit(energy)
	
	# Add gravity
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# Handle dash
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing:
		start_dash()
	
	# Get input direction
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction:
		if is_dashing:
			velocity.x = direction * dash_speed
		else:
			velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 0.2)
	
	# Flip sprite based on direction
	if direction != 0:
		sprite.flip_h = direction < 0
	
	move_and_slide()

func start_dash() -> void:
	is_dashing = true
	can_dash = false
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown

func take_damage(amount: float) -> void:
	energy -= amount
	energy_changed.emit(energy)
	
	if energy <= 0:
		die()

func die() -> void:
	died.emit()
	queue_free()

func eat_food(energy_value: float) -> void:
	energy = min(energy + energy_value, max_energy)
	energy_changed.emit(energy)
