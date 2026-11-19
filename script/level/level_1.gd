extends Node2D
var fantome_player_scene = preload("res://scene/fantome_player.tscn")
var fantome_mechant_scene = preload("res://scene/fantome_mechant.tscn")
var player_position_depart = Vector2(0,1000)
var mechant_position_depart = Vector2(0,1000)
@export var max_phase:int = 3
var phase : int = 0
var transition = false
var historique_fantomes_crees: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_phase()
	Signaux.phase_mechant_perdu.connect(mechant_perdu)
	Signaux.phase_mechant_gagne.connect(mechant_gagne)
	Signaux.phase_player_perdu.connect(player_perdu)
	Signaux.phase_player_gagne.connect(player_gagne)
	player_position_depart = %player.global_position
	mechant_position_depart = %mechant.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if transition == false:
		if $timer_phase.is_stopped() : # si le timer n'est pas lancé
			# on ecoute le clavier
			if Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("jump") or Input.is_action_pressed("tire_fleche"):
				$timer_phase.start() # On lance le timer
				# On réveille instantanément TOUS les fantômes 
				get_tree().set_group("fantome_player", "en_attente", false)
				get_tree().set_group("fantome_mechant", "en_attente", false)
		if Input.is_action_just_pressed("again") :
			annuler_phase_precedente()
		else :
			%affichage.maj_timer($timer_phase.time_left)

func change_phase():
	if max_phase == phase :
		%affichage.affiche_victoire()
		await get_tree().create_timer(3).timeout
		get_tree().change_scene_to_file("res://scene/select_niv.tscn")
	else:
		# on supperime les flech en vol
		get_tree().call_group("fleches_en_cours", "queue_free")
		# pour la transition
		transition = true
		%player.set_physics_process(false) # on immobilise tout le monde
		%mechant.set_physics_process(false)
		%player.visible = false
		%mechant.visible = false
		if phase == 0:
			%affichage.affiche_debut()
			await get_tree().create_timer(2).timeout
		else :
			%affichage.affiche_transition()
			await get_tree().create_timer(4).timeout # pause de 1,5 sec dans le code
		
		# Pause player
		%player.visible = phase%2 == 0
		%player.set_physics_process(phase%2 == 0)
		# Désactiver sa collision
		%player.get_node("CollisionShape2D").set_deferred("disabled", phase % 2 != 0)
		# On renitialise le chrono
		$timer_phase.stop()
		
		# Pause mechant
		%mechant.visible = phase%2 == 1
		%mechant.set_physics_process(phase%2 == 1)
		%mechant.get_node("CollisionShape2D").set_deferred("disabled", phase % 2 != 1)
		
		%affichage.maj_phase(phase)
		%affichage.rest_timer()
		%affichage.not_affiche_undo()
		phase += 1
		transition = false
		get_tree().call_group("fantome_player", "reinitialiser_pour_nouveau_tour",phase)
		get_tree().call_group("fantome_mechant", "reinitialiser_pour_nouveau_tour",phase)
		%player.immobile = true
		%mechant.immobile = true

# Victoire de phase
func player_gagne() -> void:
	# Fantome_player
	var history_fantome_player = %player.history.duplicate()
	%player.global_position = player_position_depart
	%player.history.clear()
	var nouv_fantome_player = fantome_player_scene.instantiate()
	nouv_fantome_player.history = history_fantome_player
	nouv_fantome_player.add_to_group("fantomes_du_joueur") # L'étiquette magique pour le supprimer après
	nouv_fantome_player.phase_naissance = phase
	add_child(nouv_fantome_player)
	historique_fantomes_crees.append(nouv_fantome_player)
	var pos_ecran_coffre = %coffre_fin.get_global_transform_with_canvas().origin
	%affichage.jouer_animation_coeur(pos_ecran_coffre) #anim coeur
	change_phase()

func mechant_gagne():
	get_tree().call_group("fantomes_du_joueur", "mourir", phase)
	# Fantome_mechant
	var history_fantome_mechant = %mechant.history.duplicate()
	%mechant.global_position = mechant_position_depart
	%mechant.history.clear()
	get_tree().set_group("fantome_mechant", "page_actu", 0) # re-play les mouvs des fantomes mechants
	var nouv_fantome_mechant = fantome_mechant_scene.instantiate()
	nouv_fantome_mechant.history = history_fantome_mechant
	nouv_fantome_mechant.phase_naissance = phase
	add_child(nouv_fantome_mechant)
	historique_fantomes_crees.append(nouv_fantome_mechant)
	# Pause perso
	get_tree().set_group("fantome_mechant", "en_attente", true) # en attente avant de jouer
	var pos_ecran_joueur = %player.get_global_transform_with_canvas().origin
	%affichage.jouer_animation_coeur(pos_ecran_joueur) # anim coeur
	change_phase()
	
# Défaite de phase
func player_perdu() -> void:
	%affichage.affiche_defaite()
	#await get_tree().create_timer(1.5).timeout # pause de 1,5 sec dans le code
	get_tree().call_group("fleches_en_cours", "queue_free")
	get_tree().call_group("fantome_mechant", "reinitialiser_pour_nouveau_tour",phase)
	%player.global_position = player_position_depart
	%player.history.clear()
	%player.immobile = true
	$timer_phase.stop() #renitialise le timer
	%affichage.rest_timer()
	%affichage.affiche_undo()

func mechant_perdu() -> void:
	%affichage.affiche_defaite()
	#await get_tree().create_timer(1.5).timeout # pause de 1,5 sec dans le code
	get_tree().call_group("fleches_en_cours", "queue_free")
	get_tree().call_group("fantome_player", "reinitialiser_pour_nouveau_tour",phase)
	get_tree().call_group("fantome_mechant", "reinitialiser_pour_nouveau_tour",phase)
	%mechant.global_position = mechant_position_depart
	%mechant.history.clear()
	%mechant.immobile = true
	$timer_phase.stop()
	%affichage.rest_timer()
	%affichage.affiche_undo()


func _on_timer_phase_timeout() -> void:
	Signaux.phase_player_perdu.emit() # Si le player n'atteint pas le coffre dans le temps imparti c'est perdu
	$timer_phase.stop()
	%affichage.rest_timer()

func annuler_phase_precedente():
	if phase <= 1:
		return 
	%affichage.reculer_coeur()
	phase -= 2 

	# On vérifie tous les fantômes présents (joueurs et méchants)
	var tous_les_fantomes = get_tree().get_nodes_in_group("fantome_player") + get_tree().get_nodes_in_group("fantome_mechant")
	
	for fantome in tous_les_fantomes:
		#  Si le fantôme n'était pas encore né à cette époque, on l'efface pour de vrai 
		if fantome.phase_naissance > phase:
			fantome.queue_free()
		
		# Si le fantôme était mort après cette époque, il ressuscite 
		elif fantome.phase_mort > phase:
			fantome.ressusciter()

	# On nettoie le plateau actuel
	get_tree().call_group("fleches_en_cours", "queue_free")
	%player.history.clear()
	%mechant.history.clear()
	%player.global_position = player_position_depart
	%mechant.global_position = mechant_position_depart

	change_phase()
