extends CharacterBody2D

signal died

const BOLT = preload("res://magicbolt.tscn")

@export var speed := 90.0
@export var shoot_range := 500.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var player: Node2D
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var shoot_cooldown := randf_range(1.5, 3.5)
var dead := false

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if player:
		var dx := player.global_position.x - global_position.x
		if abs(dx) > 5:
			velocity.x = signf(dx) * speed
			sprite.flip_h = dx < 0
		else:
			velocity.x = 0

		shoot_cooldown -= delta
		if shoot_cooldown <= 0 and global_position.distance_to(player.global_position) < shoot_range:
			shoot()
			shoot_cooldown = randf_range(2.0, 4.0)

	move_and_slide()

func shoot():
	var staff_tip := global_position + Vector2(-17.5 if sprite.flip_h else 17.5, -27.5)
	var bolt = BOLT.instantiate()
	bolt.global_position = staff_tip
	bolt.direction = staff_tip.direction_to(player.global_position)
	get_parent().add_child(bolt)

func die():
	if dead:
		return
	dead = true
	died.emit()
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0.5, 0.1), 0.1)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
