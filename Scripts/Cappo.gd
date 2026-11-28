extends AnimatedSprite2D

enum State {Idle, Casting, Fishing, Reeling}
@onready var Bobber: RigidBody2D = %Bobber
@onready var Water: Area2D = %WaterArea
@onready var ReelWindow: NinePatchRect = %ReelWindow
@onready var ReelWindowRestraint: Control = %ReelWindowRestraint
@onready var RodLine: DampedSpringJoint2D = %RodLine
@onready var RodLineVisual: Line2D = %RodLineVisual
@onready var RodTip: Marker2D = $"RodTip"
@onready var AnimPlayer: AnimationPlayer = $"AnimationPlayer"

var CurrentState: State = State.Idle
var FishingProgress = 0
var StartedCount = false
var ReelButtonOnScreen = false
var RNG: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	Water.body_entered.connect(_BobberEntersWater)
	Water.body_exited.connect(_BobberLeavesWater)
	ReelWindow.find_child("ReelButton").pressed.connect(_ReelButtonPressed)

func _input(Event: InputEvent) -> void:
	if Event.is_action_pressed("Fish"):
		if CurrentState == State.Idle: _CastLine()
		elif CurrentState == State.Fishing: _ReturnToIdle()

func _process(Delta: float) -> void:
	RodLineVisual.points = PackedVector2Array([RodTip.global_position, Bobber.global_position])
	if CurrentState == State.Idle || CurrentState == State.Casting:
		Bobber.freeze = true
		Bobber.visible = false
		RodLineVisual.visible = false
		Bobber.global_position = RodTip.global_position
		RodLine.rest_length = Bobber.global_position.distance_to(RodTip.global_position)
	elif CurrentState == State.Reeling:
		AnimPlayer.current_animation = "Reeling"
		if !AnimPlayer.is_playing(): AnimPlayer.play()

		_RandomizeReelButton(true)
		AnimPlayer.speed_scale = remap(FishingProgress, 0, 100, 5, 0.2)
		FishingProgress -= Delta * 5
		if FishingProgress < 0:
			_ReturnToIdle()
		elif FishingProgress > 100:
			_ReturnToIdle()

			if ReelButtonOnScreen:
				ReelWindow.global_position = Vector2(-161.0, 244)
				ReelButtonOnScreen = false

func _ReelButtonPressed():
	if CurrentState == State.Reeling && ReelButtonOnScreen:
		FishingProgress += 15
		ReelWindow.global_position = Vector2(-161.0, 244)
		ReelButtonOnScreen = false

func _RandomizeReelButton(Randomize: bool):
	if !ReelButtonOnScreen:
		if !Randomize || RNG.randi_range(1, 5) == 1:
			ReelButtonOnScreen = true
			var XRandomnessSize = round(ReelWindowRestraint.size.x)
			var YRandomnessSize = round(ReelWindowRestraint.size.y)
			ReelWindow.global_position = Vector2(
				ReelWindowRestraint.global_position.x + RNG.randi_range(-XRandomnessSize, XRandomnessSize),
				ReelWindowRestraint.global_position.y + RNG.randi_range(-YRandomnessSize, YRandomnessSize))

func _BobberEntersWater(Body: Node):
	if Body == Bobber:
		Bobber.linear_velocity *= 0.2
		Bobber.gravity_scale = -0.25

		if CurrentState == State.Fishing && !StartedCount:
			StartedCount = true
			var RandomTime = 0 # RNG.new().randf_range(3.0, 7.0)
			for i in 700:
				i += 1
				await get_tree().create_timer(0.01).timeout
				if (i / 100.0) > RandomTime: break
				if CurrentState != State.Fishing:
					StartedCount = false
					return
			FishingProgress = 20
			CurrentState = State.Reeling
			_FishingMinigame()

func _BobberLeavesWater(Body: Node): if Body == Bobber: Bobber.gravity_scale = 1
func _ReturnToIdle():
	AnimPlayer.stop()
	AnimPlayer.current_animation = "Idle"
	CurrentState = State.Idle

func _CastLine():
	CurrentState = State.Casting
	AnimPlayer.current_animation = "Wind Up"
	AnimPlayer.play()
	await AnimPlayer.animation_finished

	AnimPlayer.current_animation = "Throw"
	AnimPlayer.play()
	CurrentState = State.Fishing
	Bobber.freeze = false
	RodLineVisual.visible = true
	Bobber.visible = true
	Bobber.apply_central_impulse(Vector2(800, -350))
	await AnimPlayer.animation_finished

func _FishingMinigame():
	StartedCount = false
	_RandomizeReelButton(false)
