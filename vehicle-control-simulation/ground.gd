extends CSGMesh3D



func _on_area_3d_body_entered(body):
	position += Vector3(0, 0, -225)
