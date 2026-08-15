extends TextureButton

func _ready() -> void:
	texture_normal = _trim(texture_normal)
	if texture_hover:
		texture_hover = _trim(texture_hover)
	if texture_pressed:
		texture_pressed = _trim(texture_pressed)
		
	var img := texture_normal.get_image()
	var bm := BitMap.new()
	bm.create_from_image_alpha(img, 0.5)
	texture_click_mask = bm

func _trim(tex: Texture2D) -> Texture2D:
	if tex == null:
		return null
	var img := tex.get_image()
	var used := img.get_used_rect()
	if used.size == img.get_size():
		return tex
	var at := AtlasTexture.new()
	at.atlas = tex
	at.region = Rect2(used)
	return at
