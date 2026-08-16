class_name DemandGenerator
extends RefCounted

static func _extension(sel: Selector, s: Array) -> Dictionary:
	var out := {}
	for id in s:
		if sel.matches(id):
			out[id] = true
	return out

static func _occurrences(sel: Selector, s: Array) -> int:
	var n := 0
	for id in s:
		if sel.matches(id):
			n += 1
	return n

static func _overlaps(a: Dictionary, b: Dictionary) -> bool:
	for k in a:
		if b.has(k):
			return true
	return false

static func _sig(ext: Dictionary) -> String:
	var keys := ext.keys()
	keys.sort()
	return ",".join(keys)

static func random_sandwich(height: int) -> Array[StringName]:
	var bread: IngredientData = Ingredients.breads.pick_random()
	var fillings: Array[StringName] = []
	for ing in Ingredients.all:
		if ing.station != IngredientData.Station.BREAD:
			fillings.append(ing.id)

	var out: Array[StringName] = [bread.id]
	for i in height - 2:
		out.append(fillings.pick_random())
	out.append(bread.id)
	return out

static func _require_subjects(demands: Array, s: Array) -> void:
	var needed := {}
	for d in demands:
		if d.type == Demand.Type.TOUCH:
			needed[d.subject.key()] = d.subject

	for key in needed:
		var sel: Selector = needed[key]
		var n := _occurrences(sel, s)
		var existing: Demand = null
		for d in demands:
			if d.type == Demand.Type.COUNT_RANGE and d.subject.key() == key:
				existing = d
				break
		if existing == null:
			demands.append(Demand.count_range(sel, n, n))
		elif existing.lo == 0:
			existing.lo = n

static func _rank(d: Demand) -> int:
	match d.type:
		Demand.Type.BREAD_ENDS:  return 0
		Demand.Type.LAYER_COUNT: return 1
		Demand.Type.COUNT_RANGE: return 2
		Demand.Type.TOUCH:       return 3
	return 4

static func generate(sandwich: Array, difficulty := 0.0) -> Dictionary:
	var extra := 2 + roundi(difficulty * 4.0)          # 2 at easy, 6 at hard

	var demands: Array[Demand] = [
		Demand.bread_ends(sandwich[0]),
		Demand.layer_count(sandwich.size()),
	]

	var pool := _candidates(sandwich, difficulty)
	pool.shuffle()
	for d in pool:
		if demands.size() >= 2 + extra:
			break
		if _redundant(d, demands, sandwich):
			continue
		demands.append(d)

	_require_subjects(demands, sandwich)
	demands.sort_custom(func(a, b): return _rank(a) < _rank(b))
	return { demands = demands, singles = _singles(demands) }
	
static func _canonical_selectors(counts: Dictionary, colors: Dictionary, s: Array, difficulty: float) -> Array[Selector]:
	var groups := {}
	for sel in _selectors(counts, colors):
		var sig := _sig(_extension(sel, s))
		if not groups.has(sig):
			groups[sig] = []
		groups[sig].append(sel)

	var out: Array[Selector] = []
	for sig in groups:
		var group: Array = groups[sig]
		var ings: Array = group.filter(func(x): return x.kind == Selector.Kind.INGREDIENT)
		var cols: Array = group.filter(func(x): return x.kind == Selector.Kind.COLOR)
		if cols.is_empty():
			out.append(ings.pick_random())
		elif ings.is_empty() or randf() < difficulty:
			out.append(cols.pick_random())
		else:
			out.append(ings.pick_random())
	return out

static func _candidates(s: Array, difficulty) -> Array[Demand]:
	var out: Array[Demand] = []

	var counts := {}
	var colors := {}
	for id in s:
		if Ingredients.by_id[id].station == IngredientData.Station.BREAD:
			continue
		counts[id] = counts.get(id, 0) + 1
		var c: StringName = Ingredients.by_id[id].color_tag
		if c != &"":
			colors[c] = colors.get(c, 0) + 1

	var sels := _canonical_selectors(counts, colors, s, difficulty)

	var ext := {}
	var occ := {}
	for sel in sels:
		ext[sel.key()] = _extension(sel, s)
		occ[sel.key()] = _occurrences(sel, s)

	for sel in sels:
		var n: int = occ[sel.key()]
		out.append(Demand.count_range(sel, n, n))
		if n < s.size():
			out.append(Demand.count_range(sel, 0, n))
		if n > 0:
			out.append(Demand.count_range(sel, n, s.size()))

	for subj in sels:
		for obj in sels:
			if subj.key() == obj.key():
				continue
			if _overlaps(ext[subj.key()], ext[obj.key()]):
				continue
			for pos in [true, false]:
				var d := Demand.touch(subj, obj, pos)
				if d.check(s):
					out.append(d)

	return out

static func _selectors(counts: Dictionary, colors: Dictionary) -> Array[Selector]:
	var out: Array[Selector] = []
	for id in counts:
		out.append(Selector.ing(id))
	for c in colors:
		out.append(Selector.col(c))
	return out

static func _redundant(d: Demand, kept: Array, s: Array) -> bool:
	for k in kept:
		if k.type != d.type:
			continue
		if d.type == Demand.Type.COUNT_RANGE:
			if k.subject.key() == d.subject.key():
				return true
		elif d.type == Demand.Type.TOUCH:
			var same: bool = k.subject.key() == d.subject.key() \
				and k.object.key() == d.object.key()
			var flipped: bool = k.subject.key() == d.object.key() \
				and k.object.key() == d.subject.key()
			if same or flipped:
				return true
		elif k.describe() == d.describe():
			return true
	return false

static func _singles(demands: Array) -> Dictionary:
	var out := {}
	for d in demands:
		if d.type == Demand.Type.COUNT_RANGE and d.lo == 1 and d.hi == 1:
			out[d.subject.key()] = true
	return out
