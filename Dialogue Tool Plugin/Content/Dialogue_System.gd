@tool
extends Control

@export var dialogue_entry : Array[DialogueEntry]

@export var interaction_area : InteractionArea2D

@export var textbox_image : CompressedTexture2D

@onready var text_background_box = $CanvasLayer/Panel/TextureRect
@onready var text_box = $CanvasLayer/Panel/TextureRect/RichTextLabel
@onready var Canvas = $CanvasLayer
@onready var Buttons = $CanvasLayer/Panel/Buttons
@onready var Animation_Player = $AnimationPlayer

@onready var font  = preload("res://addons/Dialogue Tool Plugin/Content/Assets/PressStart2P.ttf")
@onready var custom_button = preload("res://addons/Dialogue Tool Plugin/Content/custom_button.tscn")

var Script_Node = preload("res://addons/Dialogue Tool Plugin/Content/script_node.tscn")

var Array_Length
var Responce_length

var index = 0
var Response_Index = 0
var interacting = false
var responding = false

var tween : Tween

func _ready():
	if textbox_image != null:
		text_background_box.texture = textbox_image
	_get_array_size()
	if Array_Length != null:
		text_box.text = dialogue_entry[index].NPC_Dialogue
	if interaction_area != null:
		interaction_area.interaction_node.short_interaction.connect(_activated)

func _get_array_size():
	Array_Length = (dialogue_entry.size() - 1)

func _activated(_instigator):
	text_box.visible_characters = 0
	if interacting == false:
		interacting = true
		index = 0
		if Array_Length != null:
			text_box.text = dialogue_entry[index].NPC_Dialogue
			start_tween()
			Canvas.visible = true
			Animation_Player.play("Show_UI")
			_set_response_buttons()
			if dialogue_entry[index].Has_Response == false:
				responding = false
		else:
			interacting = false
			Animation_Player.play("Hide_UI")

func _advance():
	for i in Buttons.get_children():
		if i.name != "advance_button":
			i.queue_free()
	text_box.visible_characters = 0
	if tween.is_running():
		kill_tween()
	index = index + 1
	if index > Array_Length:
		Animation_Player.play("Hide_UI")
		interacting = false
	else:
		text_box.text = dialogue_entry[index].NPC_Dialogue
		start_tween()
		if dialogue_entry[index].Has_Response == true:
			_set_response_buttons()
		if dialogue_entry[index].Has_Response == false:
			for n in Buttons.get_children():
				Buttons.remove_child(n)
				n.queue_free()
				responding = false

func _on_advance_button_pressed():
	if responding == false:
		_advance()

func _set_response_buttons():
	var num_of_buttons = dialogue_entry[index].Responses.size()
	var button_index_max = num_of_buttons
	
	for i in button_index_max:
		responding = true
		var button = custom_button.instantiate()
		button.text = dialogue_entry[index].Responses[i].Text
		button.name = "Button " + str(i)
		button.size.x = 256.0
		button.size.y = 64.0
		
		button.position.x = 1016.0
		button.position.y = 24 + (88 * i)
		
		button.pressed.connect(func pressed():
			if dialogue_entry[index].Responses[i].Executable == null:
				print("No Executable Script Attached")
			#elif dialogue_entry[index].Responses[i].Executable.has_method("start"):
				#dialogue_entry[index].Responses[i].Executable.start()
			else:
				var new_script = dialogue_entry[index].Responses[i].Executable.new()
				get_parent().add_child(new_script)
				if new_script.has_method("start"):
					new_script.start()
				else:
					print("Error: Executable script lacks method 'start'")
			_advance()
			)
		Buttons.add_child(button)

func start_tween():
	tween = get_tree().create_tween()
	tween.tween_property(text_box,"visible_characters", text_box.get_total_character_count(), 2.0)

func kill_tween():
	if tween != null:
		if tween.is_running():
			tween.kill()
