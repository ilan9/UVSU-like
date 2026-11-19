extends Area2D
var fleche_feu = preload("res://assets/foret_sombre/props/fleche_feu.png")
var fleche_eau = preload("res://assets/foret_sombre/props/fleche_eau.png")
var type_fleche = "feu"
var vitesse:float = 500
var direction = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if direction == -1:
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false
	if type_fleche == "feu":
		$Sprite2D.texture = fleche_feu
	else :
		$Sprite2D.texture = fleche_eau
	add_to_group("fleches_en_cours") # L'étiquette magique !


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position.x += vitesse * direction * delta


func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		queue_free()
	else:
		if type_fleche == "feu" :
			if body.name == "player" :
				Signaux.phase_player_perdu.emit()
				queue_free()
			elif body.is_in_group("fantome_player"):
				Signaux.phase_mechant_gagne.emit()
				queue_free()
		else :
			if body.name == "mechant" :
				Signaux.phase_mechant_perdu.emit()
				queue_free()
			elif body.is_in_group("fantome_mechant"):
				if body.visible == true: # si il est pas deja desactive alors la fleche peut le toucher
					var phase_actuelle = get_tree().current_scene.phase 
					body.mourir_par_fleche() # fantome note quand il est mort
					queue_free()
