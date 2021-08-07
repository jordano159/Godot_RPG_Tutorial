extends KinematicBody2D

var knockback = Vector2.ZERO
onready var stats = $Stats
onready var player_detection_zone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var bat_hurtbox = $Hurtbox
const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
export var ACCELERATION = 300
export var MAX_SPEED = 60
export var FRICTION = 300
var velocity = Vector2.ZERO

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = IDLE

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
		WANDER:
			pass
		
		CHASE:
			var player = player_detection_zone.player
			if player != null:
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
			sprite.flip_h = velocity.x < 0
	
	velocity = move_and_slide(velocity)

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	bat_hurtbox.create_hit_effect()


func _on_Stats_no_health():
	create_enemy_death_effect()
	queue_free()

func create_enemy_death_effect():
	var enemy_death_effect = EnemyDeathEffect.instance()
	get_parent().add_child(enemy_death_effect)
	enemy_death_effect.global_position = global_position

func seek_player():
	if player_detection_zone.can_see_player():
		state = CHASE
