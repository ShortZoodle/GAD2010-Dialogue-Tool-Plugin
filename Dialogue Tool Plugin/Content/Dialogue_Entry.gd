@tool
class_name DialogueEntry extends Resource

@export var NPC_Dialogue : String
@export var Has_Response : bool:
	set(value):
		Has_Response = value
		notify_property_list_changed()
@export var Responses : Array[PlayerResponseEntry]

func _validate_property(property):
	var hiddenProperties : Array[String]
	
	if self.Has_Response == false:
		hiddenProperties.append("Responses")
	
	if property.name in hiddenProperties:
		property.usage = PROPERTY_USAGE_NO_EDITOR
