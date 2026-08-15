class_name Demand
extends RefCounted

enum Type { BREAD_ENDS, LAYER_COUNT, COUNT_RANGE, TOUCH }

var type: Type
var subject: Selector
var object: Selector
var lo: int
var hi: int
var positive: bool


static func bread_ends() -> Demand:
	var d := Demand.new()
	d.type = Type.BREAD_ENDS
	return d

static func layer_count(n: int) -> Demand:
	var d := Demand.new()
	d.type = Type.LAYER_COUNT
	d.lo = n
	d.hi = n
	return d

static func count_range(sel: Selector, lo: int, hi: int) -> Demand:
	var d := Demand.new()
	d.type = Type.COUNT_RANGE
	d.subject = sel
	d.lo = lo
	d.hi = hi
	return d

static func touch(subj: Selector, obj: Selector, positive: bool) -> Demand:
	var d := Demand.new()
	d.type = Type.TOUCH
	d.subject = subj
	d.object = obj
	d.positive = positive
	return d


func check(layers: Array) -> bool:
	match type:
		Type.BREAD_ENDS:
			return layers.size() >= 2 \
				and layers[0] == &"bread" \
				and layers[-1] == &"bread"
		Type.LAYER_COUNT:
			return layers.size() == lo
		Type.COUNT_RANGE:
			var n := 0
			for id in layers:
				if subject.matches(id):
					n += 1
			return n >= lo and n <= hi
		Type.TOUCH:
			for i in layers.size():
				if not subject.matches(layers[i]):
					continue
				var found := false
				if i > 0 and object.matches(layers[i - 1]):
					found = true
				if i < layers.size() - 1 and object.matches(layers[i + 1]):
					found = true
				if positive and not found:
					return false
				if not positive and found:
					return false
			return true
	return true



func describe(singles := {}) -> String:
	match type:
		Type.BREAD_ENDS:
			return "It needs bread on the top and the bottom."
		Type.LAYER_COUNT:
			return "It must have exactly %d layers." % lo
		Type.COUNT_RANGE:
			return _describe_count()
		Type.TOUCH:
			return _describe_touch(singles)
	return ""

func _describe_count() -> String:
	if lo == hi:
		return "It must have exactly %d %s." % [lo, subject.noun(lo != 1)]
	if lo == 0:
		return "It must have no more than %d %s." % [hi, subject.noun(hi != 1)]
	return "It must have no less than %d %s." % [lo, subject.noun(lo != 1)]

func _describe_touch(singles: Dictionary) -> String:
	var s := _subject_phrase(singles)
	var o := _object_phrase(singles)
	return "%s touch %s." % [s, o]

func _subject_phrase(singles: Dictionary) -> String:
	if singles.has(subject.key()):
		var verb := "should" if positive else "shouldn't"
		return "The %s %s" % [subject.noun(), verb]
	var quant := "Every" if positive else "No"
	return "%s %s should" % [quant, subject.noun()]

func _object_phrase(singles: Dictionary) -> String:
	if singles.has(object.key()):
		return "the %s" % object.noun()
	return ("a " if positive else "any ") + object.noun()
