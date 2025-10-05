@tool
extends Node3D

@export_group("Particle Settings")
@export var amount: int = 18:
	set(value):
		amount = value
		_update_particles()

@export var emission_sphere_radius: float = 3.0:
	set(value):
		emission_sphere_radius = value
		_update_particles()

@export var quad_size: float = 3.5:
	set(value):
		quad_size = value
		_update_particles()

@export_group("Shader Settings")
@export var gradient_texture: Texture2D:
	set(value):
		gradient_texture = value
		_update_particles()

@export var vertical_gradient: Texture2D:
	set(value):
		vertical_gradient = value
		_update_particles()

func _ready():
	_update_particles()

func _update_particles():
	# Get children dynamically instead of using @onready
	var particle1 = get_node_or_null("Foliage")
	var particle2 = get_node_or_null("Foliage2")
	
	for particles in [particle1, particle2]:
		if not particles:
			continue
		
		# Set amount
		particles.amount = max(1, ceili(amount / 2.0))
		
		particles.local_coords = true
		
		# Set emission sphere radius in process material
		var material = particles.process_material as ParticleProcessMaterial
		if material:
			material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
			material.emission_sphere_radius = emission_sphere_radius
		
		# Set quad mesh size in draw pass (same value for both axes)
		var mesh = particles.draw_pass_1 as QuadMesh
		if mesh:
			mesh.size = Vector2(quad_size, quad_size)
			
			# Update shader parameters
			var shader_mat = mesh.surface_get_material(0) as ShaderMaterial
			if shader_mat:
				if gradient_texture:
					shader_mat.set_shader_parameter("gradient_texture", gradient_texture)
				if vertical_gradient:
					shader_mat.set_shader_parameter("vertical_gradient", vertical_gradient)
		
		# Restart particles to apply changes
		particles.restart()
