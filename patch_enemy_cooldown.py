import re

file_path = "/home/giahoang/dev/tinyGame/tinytinygame/scenes/enemy/enemy.tscn"
with open(file_path, "r") as f:
    content = f.read()

if "EnemyCooldown" in content:
    print("Already patched")
    exit(0)

# Add ext_resource for enemy_cooldown.gd
last_ext_idx = content.rfind("[ext_resource")
end_of_last_ext = content.find("\n", last_ext_idx) + 1

ext_resource = '[ext_resource type="Script" uid="uid://xcool123" path="res://systems/enemy/enemy_cooldown.gd" id="X_cool"]\n'
content = content[:end_of_last_ext] + ext_resource + content[end_of_last_ext:]

# Replace EnemyAI block to add cooldown NodePath and EnemyCooldown node
ai_idx = content.find('[node name="EnemyAI"')
end_ai_idx = content.find('\n\n', ai_idx)

new_nodes = """[node name="EnemyCooldown" type="Node" parent="." unique_id=987654331]
script = ExtResource("X_cool")

[node name="EnemyAI" type="Node2D" parent="." unique_id=987654323 node_paths=PackedStringArray("sensor", "state_machine", "enemy_direction", "movement", "cooldown")]
script = ExtResource("X_ai")
sensor = NodePath("../EnemySensor")
state_machine = NodePath("../EnemyStateMachine")
enemy_direction = NodePath("../EnemyDirection")
movement = NodePath("../EnemyMovement")
enemy_data = ExtResource("5_edata")
cooldown = NodePath("../EnemyCooldown")"""

content = content[:ai_idx] + new_nodes + content[end_ai_idx:]

with open(file_path, "w") as f:
    f.write(content)
print("Patched successfully")
