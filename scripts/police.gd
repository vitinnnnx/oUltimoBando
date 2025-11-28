extends CharacterBody2D

enum PoliceState {
	walk,
	attack,
	dead
}
const BULLET = preload("uid://q1xrpuo6y70")
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var bullet_start_position: Node2D = $BulletStartPosition



const SPEED = 60.0
const JUMP_VELOCITY = -400.0

var status: PoliceState
var direction = 1
var can_throw = true

func _ready() -> void:
	go_to_walk_state()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		PoliceState.walk:
			walk_state(delta)
		PoliceState.dead:
			dead_state(delta)
		PoliceState.attack:
			attack_state(delta)
		

	move_and_slide()
	
func go_to_walk_state():
	status = PoliceState.walk
	anim.play("walk")
	
func go_to_attack_state():
	status = PoliceState.attack
	anim.play("attack")
	velocity = Vector2.ZERO
	can_throw = true
	throw_bullet()
func go_to_dead_state():
	status = PoliceState.dead
	anim.play("death")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO
	
func walk_state(_delta):
	velocity.x = SPEED * direction
	
	if wall_detector.is_colliding():
		direction *= -1
		scale.x *= -1
		
	if not ground_detector.is_colliding():
		scale.x *= -1
		direction *= -1
		
	if player_detector.is_colliding():
		go_to_attack_state()
		return

func attack_state(_delta):
	if anim.frame == 2 && can_throw:
		throw_bullet()
		can_throw = false
	
	
func dead_state(_delta):
	pass
func take_damage():
	go_to_dead_state()
	
func throw_bullet():
	var new_bullet = BULLET.instantiate()
	add_sibling(new_bullet)
	new_bullet.position = bullet_start_position.global_position
	new_bullet.set_direction(self.direction)

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		go_to_walk_state()
		return
		
		
