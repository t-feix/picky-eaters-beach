extends Control

const ROW := preload("res://scenes/speech_bubble/demand_row.tscn")

@onready var list: VBoxContainer = %DemandList
var _home_y: float = 0.0

func _ready() -> void:
	_home_y = position.y
	visible = false

func show_demands(entries: Array) -> void:
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()
	for e in entries:
		var row: DemandRow = ROW.instantiate()
		list.add_child(row)
		row.setup(e.text, e.status)

func set_status(idx: int, s: DemandRow.Status) -> void:
	if idx < 0 or idx >= list.get_child_count():
		return
	var row: DemandRow = list.get_child(idx)
	row.status = s

func float_in(duration := 0.5) -> void:
	Audio.play(Audio.PAGE_TURN)
	visible = true
	position.y = _home_y - size.y - 200.0
	modulate.a = 0.0
	var t := create_tween().set_parallel(true)
	t.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "position:y", _home_y, duration)
	t.tween_property(self, "modulate:a", 1.0, duration * 0.5)
	await t.finished

func float_out(duration := 0.35) -> void:
	Audio.play(Audio.PAGE_TURN)
	var t := create_tween().set_parallel(true)
	t.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.tween_property(self, "position:y", _home_y - size.y - 200.0, duration)
	t.tween_property(self, "modulate:a", 0.0, duration)
	await t.finished
	visible = false
	position.y = _home_y

func _can_drop_data(_pos: Vector2, data) -> bool:
	return data is Dictionary and data.has(&"ingredient_id")

func _drop_data(_pos: Vector2, _data) -> void:
	pass
