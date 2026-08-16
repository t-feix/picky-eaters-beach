extends Node

const WALK_IN   := preload("res://sfx/CustomerWalkUp.wav")
const WALK_OUT  := preload("res://sfx/CustomerWalkAway.wav")
const JINGLE    := preload("res://sfx/CorrectJingle.wav")

const VOICES := {
	&"man_1":   preload("res://sfx/Man1.wav"),
	&"man_2":   preload("res://sfx/Man2.wav"),
	&"woman_1": preload("res://sfx/Woman1.wav"),
	&"woman_2": preload("res://sfx/Woman2.wav"),
}

var _players: Array[AudioStreamPlayer] = []

const BUZZER    := preload("res://sfx/IncorrectChoice.wav")
const PAGE_TURN := preload("res://sfx/PageTurn.wav")

const MUSIC_INTRO := preload("res://music/BeachThemeIntro.wav")
const MUSIC_LOOP  := preload("res://music/BeachThemeLoop.wav")


const INGREDIENT := {
	IngredientData.SoundKind.DRY:     preload("res://sfx/DryIngredient.wav"),
	IngredientData.SoundKind.WET:     preload("res://sfx/WetIngredient.wav"),
	IngredientData.SoundKind.KETCHUP: preload("res://sfx/Ketchup.wav"),
	IngredientData.SoundKind.THICK:   preload("res://sfx/ThickSauce.wav"),
}

var _music: AudioStreamPlayer

func play_ingredient(ing: IngredientData) -> void:
	play(INGREDIENT[ing.sound_kind], randf_range(0.92, 1.08))

func _ready() -> void:
	for i in 8:
		var p := AudioStreamPlayer.new()
		p.bus = &"SFX"
		add_child(p)
		_players.append(p)
	
	_music = AudioStreamPlayer.new()
	_music.bus = &"Music"
	add_child(_music)
	_music.finished.connect(_on_music_finished)
	print("AUDIO buses: music=", AudioServer.get_bus_index(&"Music"),
		" sfx=", AudioServer.get_bus_index(&"SFX"))
	print("AUDIO streams: intro=", MUSIC_INTRO, " loop=", MUSIC_LOOP)

func start_music() -> void:
	print("START_MUSIC bus=", _music.bus, " stream=", _music.stream)
	_music.stream = MUSIC_INTRO
	_music.play()
	print("  playing=", _music.playing,
		" len=", MUSIC_INTRO.get_length(),
		" vol=", AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music")))

func _on_music_finished() -> void:
	print("MUSIC finished, switching to loop")
	if _music.stream != MUSIC_LOOP:
		_music.stream = MUSIC_LOOP
		_music.play()

func play(stream: AudioStream, pitch := 1.0, volume_db := 0.0) -> AudioStreamPlayer:
	if stream == null:
		return null
	for p in _players:
		if not p.playing:
			p.stream = stream
			p.pitch_scale = pitch
			p.volume_db = volume_db
			p.play()
			return p
	return null

func stop_all() -> void:
	for p in _players:
		p.stop()
