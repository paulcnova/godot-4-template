
class_name FlatRaycastProber
extends RefCounted

#region Properties

var layer: Layers.Physics3D;
var segments: int;
var plane: Plane;
var colliders: Dictionary[Node3D, int];

signal raycast(origin: Vector3, direction: Vector3, distance: float);
signal raycast_reset();

#endregion Properties

#region Public Methods

func probe(world: World3D, start: Vector3, max_distance: float, debug: bool = false) -> ArrayMesh:
	var mesh := ArrayMesh.new() if debug else null;
	var space := world.direct_space_state;
	var origin := self._project(start);
	var vertices: Array[Vector3] = [];
	
	self.colliders.clear();
	self.raycast_reset.emit();
	
	for i in range(0, self.segments + 1):
		var angle := 2.0 * PI * i / float(self.segments);
		var direction := Vector3(cos(angle), 0.0, sin(angle));
		var query := PhysicsRayQueryParameters3D.create(
			origin,
			origin + direction * max_distance,
			self.layer
		);
		var info: Dictionary = space.intersect_ray(query);
		var is_hit := info.size() > 0;
		var position: Vector3 = (self._project(info.get("position") as Vector3)
			if is_hit
			else origin + direction * max_distance);
		
		if debug:
			vertices.push_back(origin + direction * 0.5);
			vertices.push_back(position);
		self.raycast.emit(origin, direction, (position - origin).length());
		
		if not is_hit: continue;
		
		var collider := info.get("collider") as Node3D;
		
		if not self.colliders.has(collider):
			self.colliders.set(collider, 0);
		self.colliders[collider] += 1;
	if debug:
		var surface: Array = [];;
		
		surface.resize(Mesh.ArrayType.ARRAY_MAX);
		surface[Mesh.ArrayType.ARRAY_VERTEX] = vertices;
		
		mesh.add_surface_from_arrays(Mesh.PrimitiveType.PRIMITIVE_LINES, surface);
	return mesh;

#endregion Public Methods

#region Private Methods

func _project(vector: Vector3) -> Vector3: return self.plane.project(vector);

#endregion Private Methods
