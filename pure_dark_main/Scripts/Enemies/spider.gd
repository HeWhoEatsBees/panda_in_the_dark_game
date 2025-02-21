extends CharacterBody2D

const SPEED = 60

enum Spider_State {
	walking,
	prep,
	attack
}

var direction = 1

@onready var ray_cast_left: RayCast2D = $ray_cast_left
@onready var ray_cast_right: RayCast2D = $ray_cast_right
@onready var ray_cast_ground: RayCast2D = $ray_cast_ground  # New RayCast2D for ground detection
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_collision: Area2D = $attack_radius

var current_state: Spider_State = Spider_State.walking
var new_state = current_state
var at_edge = false  # To track if the spider is at the edge

func _physics_process(delta):
	if current_state == Spider_State.walking:
		if is_player_in_attack_radius():
			current_state = Spider_State.prep
			animated_sprite_2d.play("prep")
			velocity.x = 0
			await get_tree().create_timer(0.5).timeout
			current_state = Spider_State.attack
			animated_sprite_2d.play("attack")
		else:
			animated_sprite_2d.play("walk")
			velocity.x = SPEED * direction
			move_and_slide()

			check_for_wall()
			check_for_edge()  # Check for ledge and avoid spasming

	elif current_state == Spider_State.attack:
		if not is_player_in_attack_radius():
			current_state = Spider_State.walking
			animated_sprite_2d.play("walk")
			velocity.x = SPEED * direction
			move_and_slide()
			check_for_wall()

# Function to check if the spider is near a wall
func check_for_wall():
	if (ray_cast_left.is_colliding() and direction == -1) or (ray_cast_right.is_colliding() and direction == 1):
		direction *= -1
		animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h

# Function to check if the spider is at the edge of a ledge
func check_for_edge():
	if not ray_cast_ground.is_colliding():  # No ground ahead
		if !at_edge:  # Only flip direction once when we first detect the edge
			direction *= -1
			animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
			at_edge = true  # Set flag to indicate edge has been detected
	else:
		at_edge = false  # Reset the flag when ground is detected again

# Function to check if the player is in attack radius
func is_player_in_attack_radius():
	for body in attack_collision.get_overlapping_bodies():
		if body.name == "panda":
			return true
	return false
