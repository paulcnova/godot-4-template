
class_name PlanePicker
extends ScreenPicker

#region Properties

var plane: Plane = Plane.PLANE_XZ;

#endregion Properties

#region Private Methods

func _raycast_missed(origin: Vector3, direction: Vector3, _camera: Camera3D, _layers: Layers.Physics3D) -> void:
	var ray_distance: float = (self.plane.d * self.plane.normal - origin).dot(self.plane.normal) / self.plane.normal.dot(direction);
	
	self.position = origin + direction * ray_distance;
	self.normal = self.plane.normal;

#endregion Private Methods
