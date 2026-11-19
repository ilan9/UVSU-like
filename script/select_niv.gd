extends Control

@export var nbr_niv: int = 6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(0, nbr_niv):
		# fabrique les boutons
		var bouton = Button.new()
		bouton.text = str(i)
		bouton.custom_minimum_size = Vector2(80, 80)
		
		# Gerer l'interactivité du boutton
		# Le ".bind(i)" permet de donner le numéro du niveau à la fonction !
		bouton.pressed.connect(lancer_niveau.bind(i))
		
		# On place le bouton dans la Grille (elle gère la position toute seule)
		$GridContainer.add_child(bouton)

func lancer_niveau(numero_niveau: int) -> void:
	var chemin_niveau = "res://scene/level/level_" + str(numero_niveau) + ".tscn" # chamin vers niveau
	get_tree().change_scene_to_file(chemin_niveau) # on change de scene



func _on_retour_button_down() -> void:
	get_tree().change_scene_to_file("res://scene/menu.tscn")
