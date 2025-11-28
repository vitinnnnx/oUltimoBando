extends CharacterBody2D


enum PlayerState {
	idle,
	walk,
	jump,
	dead
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var reload_timer: Timer = $ReloadTimer
@export var max_speed = 300.0
@export var aceleration = 100
@export var deceleration = 100
const JUMP_VELOCITY = -500.0

var direction = 0
var status: PlayerState

func move(delta):
	update_direction()

	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, aceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, direction  * max_speed, deceleration * delta)

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match status: 
		PlayerState.idle:
			idle_state(delta)
			anim.play("idle")
		PlayerState.walk:
			walk_state(delta)
			anim.play("walk")
		PlayerState.jump:
			jump_state(delta)
		PlayerState.dead:
			dead_state(delta)
	move_and_slide()


func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")
func go_to_walk_state():
	status = PlayerState.walk
	anim.play("walk")
func go_to_jump_state():
	status = PlayerState.jump
	velocity.y = JUMP_VELOCITY
func go_to_dead_state():
	status = PlayerState.dead
	anim.play("dead")
	reload_timer.start()
	velocity.x = 0
	

func idle_state(delta):
	move(delta)
	if velocity.x != 0:
		go_to_walk_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

func jump_state(delta):
	move(delta)
	if is_on_floor():
		if velocity.x == 0:
			go_to_idle_state()
		else: 
			go_to_walk_state()
		return
		
func walk_state(delta ):
	move(delta)
	if velocity.x == 0:
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

func dead_state(_delta):
	pass
	
	

func update_direction():
	direction = Input.get_axis("left", "right")
	
	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false
		


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("inimigos"):
		hit_enemy(area)
	elif area.is_in_group("LethalArea"):
		hit_lethal_area()

func hit_enemy(area: Area2D):
	if velocity.y > 0:
		area.get_parent().take_damage()
		go_to_jump_state()
	else:
		if status != PlayerState.dead:
			go_to_dead_state()
	
func hit_lethal_area():
	go_to_dead_state()

func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()
