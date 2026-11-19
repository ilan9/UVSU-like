extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var fleche = preload("res://scene/fleche.tscn") # Adapte bien le chemin de ton dossier !

@export var SPEED = 300.0

const JUMP_VELOCITY = -400.0
var history : Array = []
var immobile = true
var fleche_tire = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		immobile = false
	
	# Pour les trappes
	if Input.is_action_just_pressed("down") and is_on_floor():
		set_collision_mask_value(3, false)
		await get_tree().create_timer(0.25).timeout
		set_collision_mask_value(3, true)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Animations
	if is_on_floor() :
		if direction > 0:
			animated_sprite_2d.play("walk")
			animated_sprite_2d.flip_h = false
			immobile = false
		elif direction < 0:
			animated_sprite_2d.play("walk")
			animated_sprite_2d.flip_h = true
			immobile = false
		else:
			animated_sprite_2d.play("idle")
	else :
		animated_sprite_2d.play("jump")

	move_and_slide()
	if Input.is_action_just_pressed("tire_fleche") :
		fleche_tire = true
		tirer_fleche(animated_sprite_2d.flip_h)
		immobile = false
	
	# Enregistrement des actions
	if immobile == false:
		var info_frame = {
			"position" : global_position,
			"animation" : animated_sprite_2d.animation,
			"flip" : animated_sprite_2d.flip_h,
			"fleche" : fleche_tire
		}
		history.append(info_frame)
	fleche_tire = false

"""
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("fantome_mechant"):
		Signaux.phase_player_perdu.emit()
"""
func tirer_fleche(est_retourne):
	var nouv_fleche = fleche.instantiate()
	if est_retourne :
		nouv_fleche.direction = -1
	nouv_fleche.type_fleche = "eau"
	get_parent().add_child(nouv_fleche)
	nouv_fleche.global_position = global_position
