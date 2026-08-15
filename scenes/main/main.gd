extends Control

enum State { EMPTY, ARRIVING, ORDERING, BUILDING, LEAVING }

@onready var customer: Control    = %Customer
@onready var bubble: Control      = %SpeechBubble
@onready var build_area: Control  = %BuildArea
@onready var serve_button: TextureButton = %ServeButton

var state: State = State.EMPTY
var served: int = 0

var current: Array[Demand] = []
var singles := {}

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	randomize()
	serve_button.pressed.connect(_on_serve)
	_set_state(State.EMPTY)
	_next_customer()

func _set_state(s: State) -> void:
	state = s
	var can_build := s == State.BUILDING
	build_area.mouse_filter = Control.MOUSE_FILTER_STOP if can_build else Control.MOUSE_FILTER_IGNORE
	bubble.visible = s == State.ORDERING or s == State.BUILDING
	serve_button.visible = bubble.visible
	serve_button.disabled = not can_build

func _next_customer() -> void:
	_set_state(State.ARRIVING)
	customer.visible = true
	customer.position.x = _offscreen_x()
	var t := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(customer, "position:x", _home_x(), 0.6)
	await t.finished
	_present_order()

func _present_order() -> void:
	_set_state(State.ORDERING)
	var height := randi_range(6, 10)
	var s := DemandGenerator.random_sandwich(height)
	var g := DemandGenerator.generate(s, round((height + 3) / 2))

	current = g.demands
	singles = g.singles

	var rows := []
	for d in current:
		rows.append({ text = d.describe(singles), status = DemandRow.Status.PENDING })
	bubble.show_demands(rows)
	await get_tree().create_timer(0.4).timeout
	_set_state(State.BUILDING)

func _on_serve() -> void:
	if state != State.BUILDING:
		return

	var all_met := true
	for i in current.size():
		var met: bool = current[i].check(build_area.layers)
		bubble.set_status(i, DemandRow.Status.MET if met else DemandRow.Status.VIOLATED)
		all_met = all_met and met

	if not all_met:
		return

	served += 1
	_set_state(State.LEAVING)
	build_area.clear()
	var t := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.tween_property(customer, "position:x", _offscreen_x(), 0.5)
	await t.finished
	customer.visible = false
	await get_tree().create_timer(0.3).timeout
	_next_customer()

func _home_x() -> float:
	return size.x * 0.25 - customer.size.x * 0.5

func _offscreen_x() -> float:
	return -customer.size.x - 50.0
