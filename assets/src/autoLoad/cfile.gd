extends Node

# 매개변수 path에 경로 넣으면 경로에 있는 json 파일 데이터 리스트로 반환
func get_jsonData(path : String):
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var data = JSON.parse_string(content)
		return data
	else:
		return null

# 폴더의 경로와 확장자 이름(예 : .json)을 넣어주면
# 그 폴더에 있는 그 확장자 파일 경로 리스트로 반환
func get_filesPath(folder_path: String, extension: String) -> Array:
	var file_list := []
	var dir := DirAccess.open(folder_path)
	
	if dir == null:
		return file_list
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if !dir.current_is_dir() and file_name.ends_with(extension):
			file_list.append(folder_path + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	return file_list
