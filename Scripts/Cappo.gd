extends AnimatedSprite2D

enum State{Idle, Casting, Fishing, Reeling}
@onready var Bobber: RigidBody2D = %Bobber
@onready var Water: Area2D = %WaterArea
@onready var RodLine: DampedSpringJoint2D = %RodLine
@onready var RodTip: Marker2D = $"RodTip"
@onready var AnimPlayer: AnimationPlayer = $"AnimationPlayer"

var CurrentState: State = State.Idle

func _ready() -> void:
	Water.body_entered.connect(_BobberEntersWater)
	Water.body_exited.connect(_BobberLeavesWater)

func _input(Event: InputEvent) -> void:
	if Event.is_action_pressed("Fish"):
		if CurrentState == State.Idle: _CastLine()
		elif CurrentState == State.Fishing: _CancelFish()

func _process(_Delta: float) -> void:
	if CurrentState != State.Fishing:
		Bobber.freeze = true
		Bobber.visible = false
		Bobber.global_position = RodTip.global_position
		RodLine.rest_length = Bobber.global_position.distance_to(RodTip.global_position)

func _BobberEntersWater(Body: Node):
	if Body == Bobber:
		Bobber.linear_velocity *= 0.2
		Bobber.gravity_scale = -0.5

func _BobberLeavesWater(Body: Node):
	if Body == Bobber:
		Bobber.gravity_scale = 1

func _CancelFish():
	AnimPlayer.stop()
	AnimPlayer.current_animation = "Idle"
	CurrentState = State.Idle

func _CastLine():
	CurrentState = State.Casting
	AnimPlayer.current_animation = "Wind Up"
	AnimPlayer.play()
	await AnimPlayer.animation_finished

	AnimPlayer.current_animation = "Reel"
	AnimPlayer.play()
	CurrentState = State.Fishing
	Bobber.freeze = false
	Bobber.visible = true
	Bobber.apply_central_impulse(Vector2(800, -350))
	await AnimPlayer.animation_finished
