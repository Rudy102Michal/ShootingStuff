extends Spatial

var blast_progress : float
var elapsed_time : float
var finished : bool

export var max_radius = 8.0
export var radius : float = 1.0
export var duration : float = 1.0
var manager : Node
var recoil_force = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	elapsed_time = 0.0
	finished = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not finished:
		elapsed_time += delta
		blast_progress = smoothstep(0.0, duration, elapsed_time)
		$BlastMesh.get_surface_material(0).set_shader_param("DissolveProgress", blast_progress + 0.2)
#		print(blast_progress)
		radius = range_lerp(blast_progress, 0.0, 1.0, 0.5, max_radius)
		#global_scale(Vector3(radius, radius, radius))
		$BlastMesh.get_surface_material(0).set_shader_param("BlastSize", radius)
	if blast_progress >= 1.0:
		finished = true
		manager.blast_finished(self)
		
func set_manager(mng : Node) -> void:
	manager = mng
		