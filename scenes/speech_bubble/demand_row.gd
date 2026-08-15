class_name DemandRow
extends PanelContainer

enum Status { PENDING, MET, VIOLATED }

const COL_MET      := Color(0.28, 0.62, 0.30)
const COL_VIOLATED := Color(0.78, 0.24, 0.24)
const COL_PENDING  := Color(0.45, 0.45, 0.45)

@onready var label: Label = %Text

var status: Status = Status.PENDING:
	set(value):
		status = value
		if is_node_ready():
			_refresh()

func setup(text: String, s: Status = Status.PENDING) -> void:
	if not is_node_ready():
		await ready
	label.text = text
	status = s

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	var c := COL_PENDING
	match status:
		Status.MET:      c = COL_MET
		Status.VIOLATED: c = COL_VIOLATED
	label.add_theme_color_override(&"font_color", c)
