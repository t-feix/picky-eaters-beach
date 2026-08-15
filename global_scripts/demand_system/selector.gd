class_name Selector
extends RefCounted

enum Kind { INGREDIENT, COLOR }

var kind: Kind
var value: StringName

func _init(k: Kind, v: StringName) -> void:
	kind = k
	value = v

static func ing(v: StringName) -> Selector:
	return Selector.new(Kind.INGREDIENT, v)

static func col(v: StringName) -> Selector:
	return Selector.new(Kind.COLOR, v)

func matches(id: StringName) -> bool:
	if kind == Kind.INGREDIENT:
		return id == value
	return Ingredients.by_id[id].color_tag == value

func key() -> String:
	return "%d:%s" % [kind, value]

func noun(plural := false) -> String:
	if kind == Kind.COLOR:
		return "%s ingredients" % value if plural else "%s ingredient" % value
	var d: IngredientData = Ingredients.by_id[value]
	return d.unit_plural if plural else d.unit_singular
