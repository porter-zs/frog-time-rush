class_name CharacterState extends State

var actor: Object
var state_machine: StateMachine

func _init(my_actor: Object) -> void:
	actor = my_actor
	state_machine = my_actor.state_machine

func _ready() -> void:
	pass

func _animate_sprite() -> void:
	pass
