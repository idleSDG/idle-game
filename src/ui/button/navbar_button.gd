extends TextureButton

func select_button(button: Control):
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_QUAD)

func deselect_button(button: Control):
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_QUAD)
