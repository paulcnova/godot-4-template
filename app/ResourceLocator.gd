
class_name ResourceLocator

#region Public Methods

static func has_files(path: String) -> bool:
	if not DirAccess.dir_exists_absolute(path): return false;
	var files: Array[String] = get_files(path, false);
	return files.size() > 0;

static func get_files(path: String, recursive: bool = true) -> Array[String]:
	if path.ends_with('/') or path.ends_with('\\'):
		path = path.substr(0, path.length() - 1);
	var files: Array[String] = [];
	
	for file in DirAccess.get_files_at(path):
		files.push_back("%s/%s" % [path, file]);
	if recursive:
		for sub_dir in DirAccess.get_directories_at(path):
			for file in get_files("%s/%s" % [path, sub_dir], recursive):
				files.push_back(str(file));
	return files;

static func get_files_with_suffix(path: String, suffix: String, recursive: bool = true) -> Array[String]:
	var results: Array[String] = [];
	var regex: RegEx = RegEx.create_from_string("\\.%s\\.t?res(\\.remap)?$" % suffix);
	
	for file in get_files(path, recursive):
		if regex.search(file):
			results.push_back(file);
	return results;

static func load_all(path: String, type_hint: String = "Resource", recursive: bool = true) -> Array[Resource]:
	var resources: Array[Resource] = [];
	
	for file in get_files(path, recursive):
		var corrected: String = _correct_file_name(file);
		
		if ResourceLoader.exists(corrected):
			var resource := ResourceLoader.load(corrected, type_hint);
			
			if resource != null:
				resources.push_back(resource);
	return resources;

static func load_all_with_suffix(path: String, suffix: String, type_hint: String = "Resource", recursive: bool = true) -> Array[Resource]:
	var resources: Array[Resource] = [];
	
	for file in get_files_with_suffix(path, suffix, recursive):
		var corrected: String = _correct_file_name(file);
		
		if ResourceLoader.exists(corrected):
			var resource := ResourceLoader.load(corrected, type_hint);
			
			if resource != null:
				resources.push_back(resource);
	return resources;

#endregion Public Methods

#region Private Methods

static func _correct_file_name(filename: String) -> String: return filename.replace(".remap", "");

#endregion Private Methods
