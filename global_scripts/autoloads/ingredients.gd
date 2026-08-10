extends Node

const ROOT := "res://global_assets/tray_ingredients/"

static func trim(tex: Texture2D) -> Texture2D:
	var img := tex.get_image()
	var used := img.get_used_rect()
	if used.size == img.get_size():
		return tex
	var at := AtlasTexture.new()
	at.atlas = tex
	at.region = Rect2(used)
	return at

var all: Array[IngredientData] = []
var by_id: Dictionary = {}

func _ready() -> void:
	_scan(ROOT)
	all.sort_custom(func(a, b): return a.id < b.id)
	print("Ingredients loaded: ", all.size())

func _scan(dir_path: String) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_error("Cannot open " + dir_path)
		return
	for sub in dir.get_directories():
		_scan(dir_path.path_join(sub))
	for file in dir.get_files():
		var clean := file.trim_suffix(".remap")
		if not clean.ends_with(".tres"):
			continue
		var res := load(dir_path.path_join(clean))
		if res is IngredientData:
			all.append(res)
			if res.layer_texture == null:
				var side_path := dir_path.path_join("side_%s.png" % res.id)
				if ResourceLoader.exists(side_path):
					res.layer_texture = trim(load(side_path))
				else:
					push_warning("No side view at %s" % side_path)
			by_id[res.id] = res
