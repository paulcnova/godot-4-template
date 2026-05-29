
class_name Utility

#region Properties

enum FilterType {
	Exact,
	ExactCIS,
	Subset,
	SubsetCIS,
	Contains,
	ContainsCIS,
	StartsWith,
	StartsWithCIS,
	EndsWith,
	EndsWithCIS,
	Regex,
}

#endregion Properties

#region Public Methods

static func is_null_or_empty(text: String) -> bool: return text == null or text == "";

static func instantiate(path: String) -> Node:
	if not ResourceLoader.exists(path): return null;
	var scene: PackedScene = ResourceLoader.load(path) as PackedScene;
	
	if scene == null: return null;
	return scene.instantiate();

static func get_script_name(obj: Object) -> String:
	if obj == null: return "";
	var variant: Variant = obj.get_script();
	if variant == null: return obj.get_class();
	return (variant as Script).get_global_name();

static func find_files(path: String, suffix: String) -> Array[String]:
	if path.ends_with('\\') or path.ends_with('/'):
		path = path.substr(0, path.length() - 1);
	
	var files: Array[String] = [];
	var regex: RegEx = RegEx.create_from_string("\\.%s\\.t?(?:scn|res)(?:\\.remap)?$" % suffix);
	
	for file in DirAccess.get_files_at(path):
		if regex.search(file.to_lower()):
			files.push_back("%s/%s" % [path, file]);
	
	for dir in DirAccess.get_directories_at(path):
		files.append_array(find_files("%s/%s" % [path, dir], suffix));
	return files;

static func get_planed_position(camera: Camera3D, plane: Plane) -> Vector3:
	var pos: Vector2 = camera.get_viewport().get_mouse_position();
	var origin: Vector3 = camera.project_ray_origin(pos);
	var direction: Vector3 = camera.project_ray_normal(pos);
	var ray_distance: float = (plane.d * plane.normal - origin).dot(plane.normal) / plane.normal.dot(direction);
	
	return origin + direction * ray_distance;

static func get_picked_position(camera: Camera3D, layers: Layers.Physics3D, margin: float = 0.0, default_position: Vector3 = Vector3.ZERO) -> Vector3:
	var pos: Vector2 = camera.get_viewport().get_mouse_position();
	var origin: Vector3 = camera.project_ray_origin(pos);
	var direction: Vector3 = camera.project_ray_normal(pos);
	var query := PhysicsRayQueryParameters3D.create(
		origin,
		origin + direction * camera.far,
		layers
	);
	var info: Dictionary = camera.get_world_3d().direct_space_state.intersect_ray(query);
	
	return info.get("position", default_position) + info.get("normal", Vector3.ZERO) * margin;

static func queue_free_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child);
		child.queue_free();

static func is_parent_class(node: Node, type: String) -> bool:
	var script: Script = node.get_script();
	
	while script != null:
		if script.get_global_name() == type: return true;
		script = script.get_base_script();
	return false;

static func find_child(node: Node, type: String) -> Node:
	var queue: Array[Node] = [];
	
	queue.push_back(node);
	while queue.size() > 0:
		var temp: Node = queue.pop_front();
		
		if temp == null: break;
		
		if Utility.is_null_or_empty(type): return temp;
		elif temp.get_class() == type: return temp;
		elif Utility.is_parent_class(temp, type): return temp;
		
		for child in temp.get_children():
			queue.push_back(child);
	return null;
	

static func get_children(node: Node, type: String = "", max_size: int = -1) -> Array[Node]:
	var results: Array[Node] = [];
	var queue: Array[Node] = [];
	
	queue.push_back(node);
	while queue.size() > 0:
		var temp: Node = queue.pop_front();
		
		if temp == null: break;
		
		if Utility.is_null_or_empty(type):
			results.push_back(temp);
		elif temp.get_class() == type:
			results.push_back(temp);
		elif Utility.is_parent_class(temp, type):
			results.push_back(temp);
		if max_size > 0 and results.size() >= max_size:
			return results;
		
		for child in temp.get_children():
			queue.push_back(child);
	return results;

static func get_child(node: Node, type: String = "") -> Node:
	var children := get_children(node, type, 1);
	return children[0] if children.size() > 0 else null;

static func find_parent(node: Node, type: String) -> Node:
	var parent: Node = node.get_parent();
	
	while parent != null:
		if parent.get_class() == type:
			return parent;
		parent = parent.get_parent();
	return null;

static func get_nodes_in_group(node: Node, group: String, type: String = "") -> Array[Node]:
	if node != null:
		if Utility.is_null_or_empty(type):
			return node.get_tree().get_nodes_in_group(group);
		else:
			var list: Array[Node] = [];
			
			for nd in node.get_tree().get_nodes_in_group(group):
				if nd.get_class() == type:
					list.push_back(nd);
			return list;
	return [];

static func filter(array: Array[String], type: FilterType, filter_str: String) -> Array[String]:
	var values: Array[String] = [];
	
	for item in array:
		if Utility.is_null_or_empty(item): continue;
		
		if _check_filter(type, item, filter_str):
			values.push_back(item);
	return values;

static func to_type_string(value: String) -> String:
	var regex := RegEx.create_from_string("([^\\/]+)\\.(?:gd|cs)$");
	var mt := regex.search(value);
	
	return mt.strings[1] if mt != null else value;

static func instantiate_str(value: String, defaultValue: Variant = null) -> Variant:
	var name: String = Utility.to_type_string(value);
	
	if not ClassDB.class_exists(name): return defaultValue;
	if not ClassDB.can_instantiate(name): return defaultValue;
	
	var variant: Variant = ClassDB.instantiate(name);
	
	if variant == null or typeof(variant) == TYPE_NIL: return defaultValue;
	return variant;

static func make_orphan(node: Node) -> bool:
	var parent := node.get_parent();
	if parent == null: return false;
	parent.remove_child(node);
	return true;

#endregion Public Methods

#region Private Methods

static func _check_filter(type: FilterType, left: String, right: String) -> bool:
	match type:
		FilterType.Exact: return left == right;
		FilterType.ExactCIS: return left.to_lower() == right.to_lower();
		FilterType.Contains: return left.contains(right);
		FilterType.ContainsCIS: return left.to_lower().contains(right.to_lower());
		FilterType.StartsWith: return left.begins_with(right);
		FilterType.StartsWithCIS: return left.to_lower().begins_with(right.to_lower());
		FilterType.EndsWith: return left.ends_with(right);
		FilterType.EndsWithCIS: return left.to_lower().ends_with(right.to_lower());
		FilterType.Subset: return right.contains(left);
		FilterType.SubsetCIS: return right.to_lower().contains(left.to_lower());
		FilterType.Regex: return RegEx.create_from_string(right).search(left) != null;
		_: return false;

#endregion Private Methods
