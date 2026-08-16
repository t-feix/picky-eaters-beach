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

func _ready() -> void:
	for i in 8:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)

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
