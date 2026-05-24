extends AudioStreamPlayer2D
class_name MusicPlayer

var _current_track: StringName

func _ready() -> void:
	SceneManager.tab_switched.connect(_on_tab_switched)
	BattleVariables.battle_state_changed.connect(_on_battle_state_changed)
	BattleVariables.battle_finished.connect(_on_battle_finished)
	self.play()
		
## Plays specified track. If track doesn't exist, returns ERR_DOES_NOT_EXIST.
## By default, if attempting to play track that is already playing, it will not interrupt it, but
## passing parameter 'interrupt_self' = true will interrupt the music track.
func play_track(track_name: StringName, interrupt_self: bool = false) -> Error:
	var interactive_stream = self.stream as AudioStreamInteractive
	if not interactive_stream:
		push_error("The stream on this player is not an AudioStreamInteractive resource!")
		return ERR_UNCONFIGURED
	
	if not interrupt_self and _current_track == track_name:
		return OK
	
	var playback = self.get_stream_playback() as AudioStreamPlaybackInteractive
	if not playback:
		self.play()
		playback = self.get_stream_playback() as AudioStreamPlaybackInteractive
		
	if playback:
		print(_current_track, " -> ", track_name)
		playback.switch_to_clip_by_name(track_name)
		_current_track = track_name
		return OK
		
	return ERR_CANT_CREATE
	
func _on_battle_state_changed(_old_state: BattleVariables.BattleStates, new_state: BattleVariables.BattleStates):
	if SceneManager.current_tab == "battle" and new_state == BattleVariables.BattleStates.IN_BATTLE:
		play_track("battle_1")

func _on_battle_victory():
	if SceneManager.current_tab == "battle":
		play_track("battle_victory_intro")

func _on_battle_defeat():
	if SceneManager.current_tab == "battle":
		play_track("battle_defeat_intro")
	
func _on_battle_finished(outcome: BattleVariables.BattleOutcome):
	if outcome == BattleVariables.BattleOutcome.VICTORY:
		_on_battle_victory()
	else:
		_on_battle_defeat()
	
func _on_tab_switched(tab_name: String):
	if tab_name != "battle":
		play_track("ambient_1")
		return
	
	if BattleVariables.battleState == BattleVariables.BattleStates.IN_BATTLE:
		play_track("battle_1")
	elif BattleVariables.battleState == BattleVariables.BattleStates.AWAITING_EXIT:
		if BattleVariables.last_battle_outcome == BattleVariables.BattleOutcome.VICTORY:
			play_track("battle_victory_loop")
		else:
			play_track("battle_defeat_loop")
