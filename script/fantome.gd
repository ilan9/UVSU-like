extends Node2D
var fleche = preload("res://scene/fleche.tscn") # Adapte bien le chemin de ton dossier !

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var est_mechant: bool = false
var en_attente = true
var cap_tire = true

var history: Array = []
var page_actu: int = 0

var phase_naissance: int = -1
var phase_mort: int = 999 # 999 = il n'est pas mort

# Quand une flèche ou un méchant le touche
func mourir(phase_de_la_mort: int):
	phase_mort = phase_de_la_mort
	visible = false
	cap_tire = false
	# On désactive sa boîte de collision pour que les autres flèches le traversent
	$CollisionShape2D.set_deferred("disabled", true) 

# Quand on remonte le temps avant sa mort !
func ressusciter():
	phase_mort = 999
	visible = true
	cap_tire = true
	$CollisionShape2D.set_deferred("disabled", false)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if est_mechant == true:
		remove_from_group("fantome_player")
		add_to_group("fantome_mechant")
	global_position = Vector2(0,-200)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if en_attente == false :
		if page_actu != len(history):
			var actions = history[page_actu]
			global_position = actions["position"]
			animated_sprite_2d.play(actions["animation"])
			animated_sprite_2d.flip_h = actions["flip"]
			if actions["fleche"] == true:
				if cap_tire == true :
					tirer_fleche(actions["flip"])
			page_actu += 1


func tirer_fleche(est_retourne):
	var nouv_fleche = fleche.instantiate()
	if est_retourne :
		nouv_fleche.direction = -1
	if est_mechant == false:
		nouv_fleche.type_fleche = "eau"
	get_parent().add_child(nouv_fleche)
	nouv_fleche.global_position = global_position

# Quand une flèche le touche pendant la partie
func mourir_par_fleche():
	visible = false
	cap_tire = false
	$CollisionShape2D.set_deferred("disabled", true)

func reinitialiser_pour_nouveau_tour(phase_actuelle:int):
	page_actu = 0
	en_attente = true
	# : On vérifie s'il est mort à cette époque
	if phase_mort <= phase_actuelle:
		visible = false
		cap_tire = false
		$CollisionShape2D.set_deferred("disabled", true)
	else:
		# S'il est vivant, on applique les règles du jeu !
		$CollisionShape2D.set_deferred("disabled", false)
		
		if est_mechant == false: # C'est le fantôme du JOUEUR
			# Le fantôme du joueur ne joue que pendant le tour du méchant (phases impaires : 1, 3, 5...)
			if phase_actuelle % 2 == 0:
				visible = true
				cap_tire = true
			else:
				visible = false
				cap_tire = false # Il ne tire pas s'il est invisible
				$CollisionShape2D.set_deferred("disabled", true) # Intouchable
				
		else: # C'est le fantôme du MÉCHANT
			visible = true
			cap_tire = true
	if len(history) != 0 :
		global_position = history[0]["position"]



	
	
