extends Area2D

@export var speed := 600.0
var direction := Vector2.RIGHT
var life := 1.5
var t := 0.0
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta
	t += delta
	sprite.frame = int(t * 12) % sprite.hframes
	life -= delta
	if life <= 0:
		queue_free()

func _on_body_entered(body):
	if body.has_method("die"):
		body.die()
	queue_free()
