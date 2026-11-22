extends CharacterBody2D

signal health_changed(health)
signal died

const FIREBALL = preload("res://fireball.tscn")

@export var speed := 300.0
@export var max_health := 5
@export var fire_cooldown := 0.25

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var health := 5
var fire_timer := 0.0
var invincible := 0.0

func _ready():
	add_to_group("player")
	health = max_health

func _physics_process(delta):
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	if direction.x != 0:
		sprite.flip_h = direction.x < 0

	fire_timer -= delta
	invincible -= delta
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and fire_timer <= 0:
		shoot()
		fire_timer = fire_cooldown

func shoot():
	var target := get_global_mouse_position()
	sprite.flip_h = target.x < global_position.x
	var mouth := global_position + Vector2(-39 if sprite.flip_h else 39, -9)
	var fireball = FIREBALL.instantiate()
	fireball.global_position = mouth
	fireball.direction = mouth.direction_to(target)
	get_parent().add_child(fireball)

func take_damage(amount):
	if invincible > 0 or health <= 0:
		return
	health -= amount
	invincible = 1.0
	health_changed.emit(health)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0.3, 0.3), 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)
	if health <= 0:
		died.emit()
