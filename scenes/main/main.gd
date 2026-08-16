extends Control

enum State { EMPTY, ARRIVING, ORDERING, BUILDING, LEAVING, JUDGING }

@onready var customer: Control    = %Customer
@onready var bubble: Control      = %SpeechBubble
@onready var build_area: Control  = %BuildArea
@onready var serve_button: TextureButton = %ServeButton

@onready var react_right: Sprite2D = customer.get_node("ReactionRight")
@onready var react_wrong: Sprite2D = customer.get_node("ReactionWrong")

@onready var pause_button: TextureButton = %PauseButton
@onready var tutorial: Control = %Tutorial

func _go_to_tutorial():
	get_tree().change_scene_to_file("res://scenes/tutorial/tutorial.tscn")

@export var handover_dx: float = -975
@export var handover_dy: float = -100.0

var state: State = State.EMPTY
var served: int = 0

var current: Array[Demand] = []
var singles := {}

var difficulty: float = 0.0

var rng := RandomNumberGenerator.new()

const CUSTOMER_LOOKS := [
	{ tex = preload("res://scenes/customer/customer_a.png"), voice = &"woman_1" },
	{ tex = preload("res://scenes/customer/customer_b.png"), voice = &"man_1" },
	{ tex = preload("res://scenes/customer/customer_c.png"), voice = &"man_2" },
	{ tex = preload("res://scenes/customer/customer_d.png"), voice = &"woman_2" },
	{ tex = preload("res://scenes/customer/customer_e.png"), voice = &"woman_1" },
	{ tex = preload("res://scenes/customer/customer_f.png"), voice = &"man_2" },
]

var current_voice: StringName = &"woman_1"

var _started := false


func _ready() -> void:
	randomize()
	%PauseButton.pressed.connect(_on_pause_pressed)
	tutorial.closed.connect(_close_tutorial)
	serve_button.pressed.connect(_on_serve)

	tutorial.visible = true
	get_tree().paused = true
	_set_state(State.EMPTY)

func _close_tutorial() -> void:
	get_tree().paused = false
	tutorial.visible = false
	if not _started:
		_started = true
		_next_customer()

func _on_pause_pressed() -> void:
	tutorial.visible = true
	get_tree().paused = true

func _can_drop_data(_pos: Vector2, data) -> bool:
	return data is Dictionary and data.has(&"ingredient_id")

func _drop_data(_pos: Vector2, _data) -> void:
	pass

func _set_state(s: State) -> void:
	state = s
	var can_build := s == State.BUILDING
	build_area.mouse_filter = Control.MOUSE_FILTER_STOP if can_build else Control.MOUSE_FILTER_IGNORE
	serve_button.disabled = not can_build

func _next_customer() -> void:
	_set_state(State.ARRIVING)
	var look: Dictionary = CUSTOMER_LOOKS.pick_random()
	customer.texture = look.tex
	current_voice = look.voice
	_hide_reactions()
	customer.visible = true
	customer.position.x = _offscreen_x()
	Audio.play(Audio.WALK_IN)
	var t := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	t.tween_property(customer, "position:x", _home_x(), 1.0)
	await t.finished
	await get_tree().create_timer(0.4).timeout
	_present_order()

func _present_order() -> void:
	difficulty = minf(served / 4.0, 1.0)
	_set_state(State.ORDERING)
	var height := randi_range(6 + roundi(difficulty * 2.0), 8 + roundi(difficulty * 2.0))
	var s := DemandGenerator.random_sandwich(height)
	var g := DemandGenerator.generate(s, difficulty)

	current = g.demands
	singles = g.singles

	var rows := []
	for d in current:
		rows.append({ text = d.describe(singles), status = DemandRow.Status.PENDING })
	bubble.show_demands(rows)
	Audio.play(Audio.VOICES[current_voice], randf_range(0.95, 1.05))
	await bubble.float_in()
	_set_state(State.BUILDING)
	await get_tree().create_timer(0.4).timeout
	_set_state(State.BUILDING)

func _on_serve() -> void:
	if state != State.BUILDING:
		return

	_set_state(State.JUDGING)

	var all_met := true
	for i in current.size():
		var met: bool = current[i].check(build_area.layers)
		bubble.set_status(i, DemandRow.Status.MET if met else DemandRow.Status.VIOLATED)
		all_met = all_met and met

	await get_tree().create_timer(0.5).timeout

	if not all_met:
		Audio.play(Audio.BUZZER)
		await _show_reaction(false)
		_set_state(State.BUILDING)
		return
	
	Audio.play(Audio.JINGLE)
	await _show_reaction(true)
	await build_area.collapse()
	await bubble.float_out()

	await build_area.move_to_customer(Vector2(handover_dx, handover_dy))

	await get_tree().create_timer(0.2).timeout

	served += 1
	_set_state(State.LEAVING)
	var walk_dist := _offscreen_x() - customer.position.x
	Audio.play(Audio.WALK_OUT)
	var walk := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	walk.tween_property(customer, "position:x", _offscreen_x(), 1.0)
	build_area.ride_out(walk_dist, 1.0)
	await walk.finished

	customer.visible = false
	await get_tree().create_timer(0.5).timeout
	_next_customer()

func _home_x() -> float:
	return size.x * 0.25 - customer.size.x * 0.5

func _offscreen_x() -> float:
	return -customer.size.x - 50.0

const REACT_SCALE := Vector2(0.4, 0.4)

func _show_reaction(correct: bool, hold := 0.9) -> void:
	var node := react_right if correct else react_wrong
	node.visible = true
	node.scale = Vector2.ZERO
	node.modulate.a = 1.0
	var t := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(node, "scale", REACT_SCALE, 0.25)
	t.tween_interval(hold)
	t.tween_property(node, "modulate:a", 0.0, 0.2)
	await t.finished
	node.visible = false
	node.scale = REACT_SCALE

func _hide_reactions() -> void:
	react_right.visible = false
	react_wrong.visible = false
