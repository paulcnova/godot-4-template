
class_name Random
extends Resource

#region Properties

const MAX_INT_VALUE: int = 9_223_372_036_854_775_807;

@export var _seed_str: String = "";
@export var _seed: int = -1;
@export var _value: int = -1;
@export var _iterations: int = 0;

var seed_value: int:
	get: return self._seed;
	set(value):
		self._seed = value;
		self._value = self._seed;
		self._seed_str = self._convert_to_str(value, "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789");

func _init(seed_int: int = -1, seed_str: String = "") -> void:
	if seed_int != -1:
		self.seed_value = seed_int;
	elif not Utility.is_null_or_empty(seed_str):
		self.set_seed(seed_str);
	else:
		self.seed_value = randi();

#endregion Properties

#region Public Methods

func set_seed(seed_str: String) -> void:
	self._seed_str = seed_str;
	self._seed = seed_str.hash();
	self._value = self._seed;

func range_int(min_value: int, max_value: int) -> int: return lerp(min_value, max_value, self.next_float());
func range_float(min_value: float, max_value: float) -> float: return lerpf(min_value, max_value, self.next_float());
func range_euler_2d_rotation(min_value: float, max_value: float) -> Vector2: return Vector2(self.range_float(min_value, max_value), self.range_float(min_value, max_value));
func range_euler_3d_rotation(min_value: float, max_value: float) -> Vector3: return Vector3(self.range_float(min_value, max_value), self.range_float(min_value, max_value), self.range_float(min_value, max_value));
func next_int(max_value: int = -1) -> int: return self._next() if max_value == -1 else self._next() % max_value;
# TODO: Add 0.0 to 1.0 inclusive to docs
func next_float() -> float: return float(self._next()) / MAX_INT_VALUE;
func next_vector2() -> Vector2: return Vector2(self.next_float(), self.next_float());
func next_unit_vector2() -> Vector2: return self.next_vector2().normalized();
func next_vector3() -> Vector3: return Vector3(self.next_float(), self.next_float(), self.next_float());
func next_unit_vector3() -> Vector3: return self.next_vector3().normalized();
func next_angle() -> float: return self.next_float() * TAU;
func next_angle_deg() -> float: return self.next_float() * 360.0;
func next_color() -> Color: return Color(self.next_float(), self.next_float(), self.next_float());
func next_euler_2d_rotation() -> Vector2: return Vector2(self.next_angle(), self.next_angle());
func next_euler_3d_rotation() -> Vector3: return Vector3(self.next_angle(), self.next_angle(), self.next_angle());

#endregion Public Methods

#region Private Methods

func _next() -> int:
	self._iterations += 1;
	self._value ^= self._value << 13;
	self._value ^= self._value >> 17;
	self._value ^= self._value << 5;
	self._value = abs(self._value);
	return self._value;

func _convert_to_str(value: int, code: String) -> String:
	var digit: int = -1;
	var radix: int = len(code);
	var result: String = "";
	
	while value > 0:
		digit = value % radix;
		result = code[digit] + result;
		@warning_ignore("INTEGER_DIVISION")
		value = value / radix;
	
	return result;

#endregion Private Methods
