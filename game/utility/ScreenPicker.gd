
class_name ScreenPicker
extends Object

#region Properties

var has_hit_object: bool = false;
var position: Vector3;
var normal: Vector3;
var face_index: int;
var collider_id: int;
var collider: Variant;
var shape: int;
var rid: RID;
var hit_dictionary: Dictionary;

#endregion Properties

#region Public Methods

func pick(camera: Camera3D, layers: Layers.Physics3D) -> bool:
	var pos: Vector2 = camera.get_viewport().get_mouse_position();
	var origin: Vector3 = camera.project_ray_origin(pos);
	var direction: Vector3 = camera.project_ray_normal(pos);
	
	if not self._raycast(origin, direction, camera, layers):
		self._raycast_missed(origin, direction, camera, layers);
	return self.has_hit_object;

#endregion Public Methods

#region Private Methods

func _raycast(origin: Vector3, direction: Vector3, camera: Camera3D, layers: Layers.Physics3D) -> bool:
	var query := PhysicsRayQueryParameters3D.create(
		origin,
		origin + direction * camera.far,
		layers
	);
	var info: Dictionary = camera.get_world_3d().direct_space_state.intersect_ray(query);
	
	self.has_hit_object = info.has("position");
	if self.has_hit_object:
		self.position = info.get("position", Vector3.ZERO);
		self.normal = info.get("normal", Vector3.ZERO);
		self.face_index = info.get("face_index", -1);
		self.collider = info.get("collider");
		self.collider_id = info.get("collider_id", -1);
		self.shape = info.get("shape", -1);
		self.rid = info.get("rid");
	self.hit_dictionary = info;
	return self.has_hit_object;

func _raycast_missed(_origin: Vector3, _direction: Vector3, _camera: Camera3D, _layers: Layers.Physics3D) -> void:
	return;

#endregion Private Methods
