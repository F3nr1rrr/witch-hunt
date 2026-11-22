extends Node2D

const ENEMY = preload("res://enemy.tscn")
@export var spawn_distance := 700.0
@export var ground_y := 600.0

@onready var player = $Player
@onready var label: Label = $HUD/ScoreLabel
var score := 0

func _ready():
	$SpawnTimer.timeout.connect(spawn_enemy)
	player.health_changed.connect(_on_health_changed)
	player.died.connect(_on_player_died)
	update_hud()

func spawn_enemy():
	var enemy = ENEMY.instantiate()
	var side := 1 if randf() < 0.5 else -1
	enemy.global_position = Vector2(player.global_position.x + side * spawn_distance, ground_y - 35)
	enemy.died.connect(_on_enemy_died)
	add_child(enemy)

func _on_enemy_died():
	score += 1
	update_hud()

func _on_health_changed(_health):
	update_hud()

func update_hud():
	label.text = "Score: %d    HP: %d" % [score, player.health]

func _on_player_died():
	$SpawnTimer.stop()
	player.set_physics_process(false)
	label.text = "GAME OVER  -  Score: %d" % score
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
