extends Node2D

# What state the Player is in
enum Player_State {
	Attack,         #DONE
	Death,          #DONE
	Fall,           #DONE
	Idle,           #DONE
	Jab,            #DONE
	Jump,           #DONE
	Double_Jump,    #FIX SO NOT ONLY WHEN FALLING
	Roll,           #DONE
	Run,            #DONE
	Slam,           #DONE
	Wall_Slide      #FIX UNLIMITED DOUBLE JUMP
}

#Movement Speed
const SPEED = 120.0
const JUMP_VELOCITY = -200.0
const ROLL_VELOCITY = 400

#reference what we need
@onready 
var body: CharacterBody2D = $"."
@onready 
var animations: AnimatedSprite2D = $animations
@onready 
var lantern: PointLight2D = $lantern
@onready 
var ray_cast_left: RayCast2D = $ray_cast_left
@onready 
var ray_cast_right: RayCast2D = $ray_cast_right
@onready 
var double_jump_effect: AnimatedSprite2D = $double_jump_effect


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Set the default state
var current_state: Player_State = Player_State.Idle
var new_state = current_state

#Variable to transition states properly
var attacking = false
var death = false
var jump = false
var double_jump = false
var movable = true
var roll = false
var double_jump_ready = true
var falling = false
var slam_ready = false
var light_on = false

# Handles everything related to changing states
func change_state(new_state: Player_State) -> void:
	current_state = new_state
	match current_state:
		Player_State.Attack:
			animations.play('Attack')
			movable = false
			attacking = true
			
		Player_State.Death:
			animations.play('Death')
			death = true
			movable = false
		
		Player_State.Fall:
			animations.play('Fall')
			movable = true
		
		Player_State.Idle:
			animations.play('Idle')
			movable = true
		
		Player_State.Jab:
			animations.play('Jab')
			movable = false
			attacking = true
		
		Player_State.Jump:
			animations.play('Jump')
			movable = true
		
		Player_State.Double_Jump:
			double_jump_effect.visible = true
			animations.play('Jump')
			double_jump_effect.play("jump")
			body.velocity.y = JUMP_VELOCITY
			movable = true
			double_jump = false
			double_jump_ready = false
		
		Player_State.Run:
			animations.play('Run')
			movable = true
		
		Player_State.Roll:
			body.velocity.x = ROLL_VELOCITY * animations.scale.x
			animations.play('Roll')
			movable = true
			roll = true
		
		Player_State.Slam:
			animations.play('Slam')
			movable = false
			
		Player_State.Wall_Slide:
			animations.play('Wall_Slide')
			double_jump_ready = true
			if ray_cast_left.is_colliding():
				animations.scale.x = abs(animations.scale.x)
			elif ray_cast_right.is_colliding():
				animations.scale.x = -abs(animations.scale.x)

#Handles Movement
func _physics_process(delta: float) -> void:
	# Toggle lantern visibility
	lantern.visible = light_on
	
	# Add the gravity.
	if not body.is_on_floor():
		body.velocity.y += gravity * delta/2
		if Input.is_action_just_pressed("Special"):
			slam_ready = true
	else:
		jump = false
		double_jump = false
		double_jump_ready = true
		falling = false

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and body.is_on_floor():
		body.velocity.y = JUMP_VELOCITY
		jump = true
	
	if Input.is_action_just_pressed("Jump") and jump == true and not body.is_on_floor() and double_jump_ready == true and body.velocity.y > 0:
		body.velocity.y = JUMP_VELOCITY
		double_jump = true
	
	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("Left", "Right")

	# Flip the Sprite
	if direction > 0 and movable == true:
		animations.scale.x = abs(animations.scale.x)
	elif direction < 0 and movable == true:
		animations.scale.x = -abs(animations.scale.x)
	
		#Apply movement
	if direction and movable == true:
		body.velocity.x = direction * SPEED
	else:
		body.velocity.x = move_toward(body.velocity.x, 0, SPEED)	
	
	
	#CHANGE THE STATES BELOW HERE
	
	if not body.is_on_floor() and body.velocity.y > 0:
		falling = true
		# Detect if the player is touching a wall while falling

	
	#Change state based on movement
	if direction == 0:
		if attacking == false and death == false and jump == false and roll == false:
			new_state = Player_State.Idle
	else:
		if attacking == false and death == false and jump == false and roll == false:
			new_state = Player_State.Run
		
	#Attack and Death and Jump
	if Input.is_action_just_pressed("DEV-TOOL-DIE"):
		new_state = Player_State.Death
	if Input.is_action_just_pressed("Attack"):
		new_state = Player_State.Attack
	if Input.is_action_just_pressed("Jab"):
		new_state = Player_State.Jab
	if Input.is_action_just_pressed("Special"):
		light_on = !light_on
	if Input.is_action_just_pressed("Roll"):
		new_state = Player_State.Roll
	if falling == true:
		new_state = Player_State.Fall
	if jump == true and falling == false:
		new_state = Player_State.Jump
	if double_jump == true:
		new_state = Player_State.Double_Jump
	if slam_ready == true and body.is_on_floor():
		attacking = true
		slam_ready = false
		new_state = Player_State.Slam
	
	var wall_detected = (ray_cast_left.is_colliding() or ray_cast_right.is_colliding()) and falling and not body.is_on_floor()
	if wall_detected:
		new_state = Player_State.Wall_Slide

	if new_state == Player_State.Wall_Slide:
		body.velocity.y = min(body.velocity.y, 50) # Slow down descent
	
	body.move_and_slide()
	change_state(new_state)


func _on_animations_animation_finished() -> void:
	if animations.animation == "Attack" or animations.animation == "Jab" or animations.animation == "Spin_Jump" or animations.animation == "Slam":
		attacking = false
	if animations.animation == "Roll":
		roll = false
	#GET RID OF THIS ONCE DEATH MECHANIC IS ACTIVE
	if animations.animation == "Death":
		death = false


func _on_double_jump_effect_animation_finished() -> void:
	if double_jump_effect.animation == "jump":
		double_jump_effect.visible = false
	
