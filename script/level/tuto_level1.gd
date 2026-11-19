extends CanvasLayer




func _process(delta: float) -> void:
	var phase_actuelle = get_parent().phase
	if phase_actuelle == 1:
		affiche_tuto_1()
	elif phase_actuelle == 2:
		affiche_tuto_2()
	elif phase_actuelle == 3:
		affiche_tuto_3()

func affiche_tuto_1():
	$tuto_1.visible = true
func affiche_tuto_2():
	$tuto_1.visible = false
	$tuto_2.visible = true
func affiche_tuto_3():
	$tuto_2.visible = false
	$tuto_3.visible = true
