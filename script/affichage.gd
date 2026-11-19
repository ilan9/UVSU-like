extends CanvasLayer
var coeur_1 = preload("res://assets/foret_sombre/props/coeur_sablier_1.png")
var coeur_3 = preload("res://assets/foret_sombre/props/coeur_sablier_3.png")
var coeur_5 = preload("res://assets/foret_sombre/props/coeur_sablier_5.png")
var etape_coeur = 1
func _ready() -> void:
	var max_phase = get_parent().max_phase
	if max_phase == 1:
		$SpriteCoeur.texture = coeur_1
		$SpriteCoeur.hframes = 2
	elif max_phase == 3:
		$SpriteCoeur.texture = coeur_3
		$SpriteCoeur.hframes = 4
	else:
		$SpriteCoeur.texture = coeur_5
		$SpriteCoeur.hframes = 6
	etape_coeur = $SpriteCoeur.hframes - 1
	$SpriteCoeur.frame = etape_coeur

func maj_phase(num_phase):
	if num_phase %2 == 0:
		$phase_player.text = str( int($phase_player.text) + 1)
	else :
		$phase_mechant.text = str( int($phase_mechant.text) + 1)

func maj_timer(time):
	$timer.text = "%.2f secondes" % time # affiche 2 nbr apres la virgule
func rest_timer():
	$timer.text = "15.00 secondes"

func affiche_transition():
	$transition.visible = true
	await get_tree().create_timer(1.5).timeout
	$transition.visible = false

func affiche_victoire():
	$victoire.visible = true
	await get_tree().create_timer(1.5).timeout
	$victoire.visible = false

func affiche_defaite():
	$defaite.visible = true
	await get_tree().create_timer(1.5).timeout
	$defaite.visible = false

func affiche_debut():
	$debut.visible = true
	await get_tree().create_timer(1.5).timeout
	$debut.visible = false

func affiche_undo():
	$press_r.visible = true
func not_affiche_undo():
	$press_r.visible = false


# Coeur

# Cette fonction sera appelée par le Level1
func jouer_animation_coeur(pos_depart_boule: Vector2):
	var coeur = $SpriteCoeur # Ton noeud Sprite2D
	
	# On mémorise sa place et sa taille d'origine dans l'UI
	var pos_origine = coeur.global_position
	var scale_origine = coeur.scale
	
	# On calcule le centre exact de l'écran
	var centre_ecran = get_viewport().get_visible_rect().size / 2.0
	
	# ACTE 1 : Le coeur va au centre et grossit (x3 par exemple)
	var tween = create_tween()
	tween.tween_property(coeur, "global_position", centre_ecran, 1).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(coeur, "scale", Vector2(1.3, 1.3), 1)
	
	# Quand il est au centre, on lance l'Acte 2 (la boule)
	tween.tween_callback(lancer_boule.bind(pos_depart_boule, centre_ecran, pos_origine, scale_origine))

func lancer_boule(depart: Vector2, cible: Vector2, pos_origine_coeur: Vector2, scale_origine_coeur: Vector2):
	# On crée la boule d'énergie
	var boule = Sprite2D.new()
	boule.z_index = 3
	boule.scale = Vector2(2, 2)
	boule.texture = preload("res://assets/foret_sombre/props/boule_energie.png")
	add_child(boule)
	boule.global_position = depart
	
	# ACTE 2 : La boule vole jusqu'au coeur
	var tween_boule = create_tween()
	tween_boule.tween_property(boule, "global_position", cible,1.6).set_trans(Tween.TRANS_CUBIC)
	
	# ACTE 3 : La collision et le retour !
	tween_boule.tween_callback(func():
		boule.queue_free() # La boule disparaît
		
		# Le coeur change de frame (si on n'est pas déjà au maximum)
		if etape_coeur > 0:
			etape_coeur -= 1
			$SpriteCoeur.frame = etape_coeur
		
		# Le coeur retourne gentiment à sa place après une mini-pause de 0.5 seconde
		var retour_tween = create_tween()
		retour_tween.tween_property($SpriteCoeur, "global_position", pos_origine_coeur, 1).set_delay(1)
		retour_tween.parallel().tween_property($SpriteCoeur, "scale", scale_origine_coeur, 1)
	)

func reculer_coeur() :
	# Si on n'est pas déjà au maximum (3)
	if etape_coeur < 3:
		etape_coeur += 1 # On remonte d'une étape
		$SpriteCoeur.frame = etape_coeur
