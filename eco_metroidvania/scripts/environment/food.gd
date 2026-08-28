extends Area2D

class_name Food

@export var energy_value: float = 25.0
@export var decay_rate: float = 1.0
@export var max_decay_time: float = 30.0

var decay_timer: float = 0.0
var is_decaying: bool = true

signal consumed(energy: float)
signal decayed_completely

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var timer_label: Label = $TimerLabel

func _ready() -> void:
	decay_timer = max_decay_time
	area_entered.connect(_on_area_entered)
	_update_appearance()

func _process(delta: float) -> void:
	if is_decaying:
		decay_timer -= delta
		
		if decay_timer <= 0:
			decayed_completely.emit()
			queue_free()
		
		_update_appearance()

func _on_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	
	if body is Player:
		consume(body)
	elif body is Creature:
		consume_creature(body)

func consume(player: Player) -> void:
	player.eat_food(energy_value)
	consumed.emit(energy_value)
	queue_free()

func consume_creature(creature: Creature) -> void:
	creature.current_energy = min(creature.current_energy + energy_value, creature.max_energy)
	consumed.emit(energy_value)
	queue_free()

func _update_appearance() -> void:
	if sprite:
		var t = decay_timer / max_decay_time
		sprite.modulate = Color(1.0, t, t, 1.0)
		sprite.scale = Vector2(t, t)
	
	if timer_label:
		timer_label.text = "%.1f" % decay_timer
