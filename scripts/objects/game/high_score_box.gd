class_name HighScoreBox extends HBoxContainer

var name_label: Label
var value_label: Label

func _ready() -> void:
	name_label = $NameLabel
	value_label = $ValueLabel
