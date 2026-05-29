
class_name DisplayableResource
extends Resource

#region Properties

## Set to `true` when the resource itself is finished within production.
## This is used to quickly glance if the resource needs to be worked on.
@export var is_finished: bool = false;

@export var expansion_id: String = "base";

## The icon that the resource might want to display.
@export var icon: Texture2D;

## The name of the resource to display.
@export var name: String;

## The description of the resource to display.
@export_multiline("monospace") var description: String;

@export_group("Extra")
## Any extra description needed to provide for flavor text aside from the description of what the resource does.
@export_multiline("monospace") var flavor_text: String;

@export_group("Tooltips")
@export var tooltip_category: int = -1;
@export var recommended_tooltip_width: int = -1;
@export var recommended_tooltip_height: int = -1;

#endregion Properties
