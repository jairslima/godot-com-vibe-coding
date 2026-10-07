@tool
extends SceneTree

func _init() -> void:
	print("--- GERADOR DE MODELO glTF ---")
	var root: Node3D = Node3D.new()
	root.name = "StationCrate"
	
	var mesh_inst: MeshInstance3D = MeshInstance3D.new()
	mesh_inst.name = "CrateMesh"
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(1.0, 1.0, 1.0)
	
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.7, 0.45, 0.2, 1.0)
	mat.roughness = 0.5
	mat.metallic = 0.1
	box.material = mat
	
	mesh_inst.mesh = box
	root.add_child(mesh_inst)
	mesh_inst.owner = root
	
	var doc: GLTFDocument = GLTFDocument.new()
	var state: GLTFState = GLTFState.new()
	
	var err: Error = doc.append_from_scene(root, state)
	if err == OK:
		var write_err: Error = doc.write_to_filesystem(state, "res://assets/models/station_crate.glb")
		if write_err == OK:
			print("Modelo glTF (GLB) gerado com sucesso em res://assets/models/station_crate.glb")
		else:
			push_error("Erro ao gravar arquivo GLB: %d" % write_err)
	else:
		push_error("Erro ao converter cena para GLTF: %d" % err)
	
	root.free()
	quit(0)
