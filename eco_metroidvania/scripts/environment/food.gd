extends Area2D

class_name Food

@export var energy_value: float = 25.0
@export var decay_rate: float = 1.0
@export var max_decay_time: float = 30.0

var decay_timer: float = 0.0
var is_decaying: bool = true

signal consumed(energy: float)
signal decayed_completely

func _ready() -> void:
	decay_timer = max_decay_time
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if is_decaying:
		decay_timer -= delta
		
		if decay_timer <= 0:
			decayed_completely.emit()
			queue_free()

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
