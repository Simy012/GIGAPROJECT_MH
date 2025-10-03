extends Area3D
class_name HitboxComponent

## Signal, das ausgelöst wird, wenn etwas die Hitbox berührt
signal hitbox_entered(body: Node)
signal hitbox_exited(body: Node)

func _ready():
	monitoring = true
	monitorable = true
	
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node) -> void:
	emit_signal("hitbox_entered", body)

func _on_body_exited(body: Node) -> void:
	emit_signal("hitbox_exited", body)
