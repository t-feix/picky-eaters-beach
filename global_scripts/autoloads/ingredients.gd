extends Node

const ROOT := "res://global_assets/tray_ingredients/"

const FILES := [
	preload("res://global_assets/tray_ingredients/tray_bacon_veg/tray_bacon_veg.tres"),
	preload("res://global_assets/tray_ingredients/tray_meatballs/tray_meatballs.tres"),
	preload("res://global_assets/tray_ingredients/tray_tofu/tray_tofu.tres"),
	preload("res://global_assets/tray_ingredients/tray_avocado/tray_avocado.tres"),
	preload("res://global_assets/tray_ingredients/tray_cucumber/tray_cucumber.tres"),
	preload("res://global_assets/tray_ingredients/tray_lettuce/tray_lettuce.tres"),
	preload("res://global_assets/tray_ingredients/tray_paprika_green/tray_paprika_green.tres"),
	preload("res://global_assets/tray_ingredients/tray_rocula/tray_rocula.tres"),
	preload("res://global_assets/tray_ingredients/tray_cheese/tray_cheese.tres"),
	preload("res://global_assets/tray_ingredients/tray_mango/tray_mango.tres"),
	preload("res://global_assets/tray_ingredients/tray_paprika_yellow/tray_paprika_yellow.tres"),
	preload("res://global_assets/tray_ingredients/tray_paprika_red/tray_paprika_red.tres"),
	preload("res://global_assets/tray_ingredients/tray_salmon/tray_salmon.tres"),
	preload("res://global_assets/tray_ingredients/tray_tomato/tray_tomato.tres"),
	preload("res://global_assets/tray_ingredients/tray_bacon/tray_bacon.tres"),
	preload("res://global_assets/tray_ingredients/tray_ham/tray_ham.tres"),
	preload("res://global_assets/tray_ingredients/tray_shrimp/tray_shrimp.tres"),
	preload("res://global_assets/tray_ingredients/tray_onion_red/tray_onion_red.tres"),
	preload("res://global_assets/tray_ingredients/tray_onion_white/tray_onion_white.tres"),
	preload("res://global_assets/tray_ingredients/tray_chicken_breast/tray_chicken_breast.tres"),
	preload("res://global_assets/tray_ingredients/tray_egg_sunny/tray_egg_sunny.tres"),
	preload("res://global_assets/tray_ingredients/tray_mushroom/tray_mushroom.tres"),
	preload("res://global_assets/tray_ingredients/tray_bread/tray_bread.tres"),
	preload("res://global_assets/tray_ingredients/tray_bread_sourdough/tray_bread_sourdough.tres"),
	preload("res://global_assets/tray_ingredients/tray_hotsauce/tray_hotsauce.tres"),
	preload("res://global_assets/tray_ingredients/tray_ketchup/tray_ketchup.tres"),
	preload("res://global_assets/tray_ingredients/tray_mayo/tray_mayo.tres"),
	preload("res://global_assets/tray_ingredients/tray_ranch/tray_ranch.tres"),
	preload("res://global_assets/tray_ingredients/tray_mustard/tray_mustard.tres"),
	preload("res://global_assets/tray_ingredients/tray_pesto/tray_pesto.tres"),
]

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
var tray: Array[IngredientData] = []
var sauces: Array[IngredientData] = []
var breads: Array[IngredientData] = []

var by_id: Dictionary = {}

func _ready() -> void:
	for ing in FILES:
		all.append(ing)
		by_id[ing.id] = ing
		match ing.station:
			IngredientData.Station.SAUCE: sauces.append(ing)
			IngredientData.Station.BREAD: breads.append(ing)
			_:                            tray.append(ing)

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
			by_id[res.id] = res
