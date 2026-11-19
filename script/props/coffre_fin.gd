extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		animated_sprite_2d.play("ouverture")
		Signaux.phase_player_gagne.emit()
		animated_sprite_2d.play("fermeture")
	elif body.is_in_group("fantome_player"):
		animated_sprite_2d.play("ouverture")
		Signaux.phase_mechant_perdu.emit()
		animated_sprite_2d.play("fermeture")
		
