class_name TestBootstrap3D
extends Node3D

## Suíte de testes automatizados headless para homologação do marco station3d-00-bootstrap.
## Valida a hierarquia de nós 3D, convenção de eixos, matrizes Transform3D, colisão CSG e modelos glTF.

var passed_assertions: int = 0
var total_assertions: int = 6

func _ready() -> void:
	print("==================================================")
	print("SUÍTE DE TESTES: BOOTSTRAP 3D (ESTAÇÃO ESPACIAL)")
	print("==================================================")
	
	test_node_hierarchy()
	test_coordinate_system_axes()
	test_transform3d_and_basis_math()
	test_csg_collision_and_materials()
	test_camera_and_lighting_setup()
	test_gltf_model_import()
	
	print("--------------------------------------------------")
	print("RESULTADO: %d/%d asserções aprovadas com sucesso." % [passed_assertions, total_assertions])
	print("==================================================")
	
	if passed_assertions == total_assertions:
		get_tree().quit(0)
	else:
		push_error("Falha na suíte de testes de bootstrap 3D!")
		get_tree().quit(1)

func test_node_hierarchy() -> void:
	var hub_scene: PackedScene = load("res://src/levels/station_hub.tscn")
	assert(hub_scene != null, "A cena station_hub.tscn deve existir e ser carregável.")
	
	var hub_instance: Node = hub_scene.instantiate()
	assert(hub_instance is Node3D, "O nó raiz da estação deve ser um Node3D.")
	
	var world_env: Node = hub_instance.get_node_or_null("WorldEnvironment")
	var sun: Node = hub_instance.get_node_or_null("DirectionalLight3D")
	var cam: Node = hub_instance.get_node_or_null("StationCamera")
	var floor_node: Node = hub_instance.get_node_or_null("Geometry/Floor")
	var combiner: Node = hub_instance.get_node_or_null("Geometry/ArchwayCombiner")
	var pillar: Node = hub_instance.get_node_or_null("Geometry/BeaconPillar")
	var player_ph: Node = hub_instance.get_node_or_null("PlayerPlaceholder")
	
	assert(world_env is WorldEnvironment, "WorldEnvironment deve existir.")
	assert(sun is DirectionalLight3D, "DirectionalLight3D deve existir.")
	assert(cam is Camera3D, "Camera3D deve existir.")
	assert(floor_node is CSGBox3D, "Floor deve ser um CSGBox3D.")
	assert(combiner is CSGCombiner3D, "ArchwayCombiner deve ser um CSGCombiner3D.")
	assert(pillar is MeshInstance3D, "BeaconPillar deve ser um MeshInstance3D.")
	assert(player_ph is MeshInstance3D, "PlayerPlaceholder deve ser um MeshInstance3D.")
	
	hub_instance.free()
	passed_assertions += 1
	print("[TESTE 1/6 APROVADO] Hierarquia de nós 3D completa e tipada.")

func test_coordinate_system_axes() -> void:
	assert(Vector3.FORWARD == Vector3(0.0, 0.0, -1.0), "Vector3.FORWARD deve ser (0, 0, -1).")
	assert(Vector3.BACK == Vector3(0.0, 0.0, 1.0), "Vector3.BACK deve ser (0, 0, 1).")
	assert(Vector3.UP == Vector3(0.0, 1.0, 0.0), "Vector3.UP deve ser (0, 1, 0).")
	assert(Vector3.RIGHT == Vector3(1.0, 0.0, 0.0), "Vector3.RIGHT deve ser (1, 0, 0).")
	
	var cross_xy: Vector3 = Vector3.RIGHT.cross(Vector3.UP)
	assert(cross_xy == Vector3.BACK, "O produto vetorial RIGHT x UP deve resultar em BACK (+Z).")
	
	passed_assertions += 1
	print("[TESTE 2/6 APROVADO] Convenção canônica de eixos e mão direita homologada.")

func test_transform3d_and_basis_math() -> void:
	var t: Transform3D = Transform3D.IDENTITY
	assert(t.origin == Vector3.ZERO, "A origem da transformação identidade deve ser Vector3.ZERO.")
	assert(t.basis.x == Vector3.RIGHT, "O eixo X local da identidade deve ser Vector3.RIGHT.")
	assert(t.basis.y == Vector3.UP, "O eixo Y local da identidade deve ser Vector3.UP.")
	assert(t.basis.z == Vector3.BACK, "O eixo Z local da identidade deve ser Vector3.BACK.")
	
	var rot_y: Transform3D = t.rotated(Vector3.UP, PI / 2.0)
	var forward_rotated: Vector3 = rot_y.basis * Vector3.FORWARD
	assert(forward_rotated.is_equal_approx(Vector3.LEFT), "Girar 90 graus em torno de UP deve direcionar FORWARD para LEFT.")
	
	passed_assertions += 1
	print("[TESTE 3/6 APROVADO] Álgebra matricial de Transform3D e Basis validada.")

func test_csg_collision_and_materials() -> void:
	var hub_scene: PackedScene = load("res://src/levels/station_hub.tscn")
	var hub_instance: Node = hub_scene.instantiate()
	
	var floor_node: CSGBox3D = hub_instance.get_node("Geometry/Floor") as CSGBox3D
	assert(floor_node.use_collision == true, "O nó CSGBox3D do solo deve estar com use_collision ativado.")
	assert(floor_node.size.x >= 20.0 and floor_node.size.z >= 20.0, "O solo da estação deve cobrir área mínima de 20x20 metros.")
	
	var pillar: MeshInstance3D = hub_instance.get_node("Geometry/BeaconPillar") as MeshInstance3D
	assert(pillar.mesh != null, "O pilar deve possuir uma malha CylinderMesh atribuída.")
	assert(pillar.mesh.material is StandardMaterial3D, "A malha deve possuir um StandardMaterial3D.")
	
	var mat: StandardMaterial3D = pillar.mesh.material as StandardMaterial3D
	assert(mat.metallic > 0.0, "O material da estação deve possuir componente metálico.")
	assert(mat.emission_enabled == true, "O sinalizador visual deve ter emissão ativada.")
	
	hub_instance.free()
	passed_assertions += 1
	print("[TESTE 4/6 APROVADO] Colisão sólida em CSG e propriedades de StandardMaterial3D verificadas.")

func test_camera_and_lighting_setup() -> void:
	var hub_scene: PackedScene = load("res://src/levels/station_hub.tscn")
	var hub_instance: Node = hub_scene.instantiate()
	
	var cam: Camera3D = hub_instance.get_node("StationCamera") as Camera3D
	assert(cam.current == true, "A câmera da estação deve ser a câmera ativa (current = true).")
	assert(cam.fov >= 60.0 and cam.fov <= 90.0, "O campo de visão da câmera (FOV) deve estar em faixa ergonômica.")
	
	var sun: DirectionalLight3D = hub_instance.get_node("DirectionalLight3D") as DirectionalLight3D
	assert(sun.shadow_enabled == true, "A luz direcional principal deve ter sombras em tempo real ativadas.")
	assert(sun.light_energy > 0.0, "A energia da luz direcional deve ser positiva.")
	
	hub_instance.free()
	passed_assertions += 1
	print("[TESTE 5/6 APROVADO] Câmera de perspectiva e iluminação direcional com sombras confirmadas.")

func test_gltf_model_import() -> void:
	var crate_scene: PackedScene = load("res://assets/models/station_crate.glb") as PackedScene
	assert(crate_scene != null, "O modelo glTF binário (.glb) deve ser importado como PackedScene pelo Godot.")
	var crate_instance: Node = crate_scene.instantiate()
	assert(crate_instance is Node3D, "A raiz do modelo glTF instanciado deve herdar de Node3D.")
	crate_instance.free()
	passed_assertions += 1
	print("[TESTE 6/6 APROVADO] Importação e instanciação de modelo glTF (.glb) homologadas.")
