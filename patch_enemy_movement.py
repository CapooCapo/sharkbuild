import re

file_path = "/home/giahoang/dev/tinyGame/tinytinygame/scenes/enemy/enemy.tscn"
with open(file_path, "r") as f:
    content = f.read()

if "EnemyMovement" in content:
    print("Already patched")
    exit(0)

# Add ext_resource for enemy_movement.gd
last_ext_idx = content.rfind("[ext_resource")
end_of_last_ext = content.find("\n", last_ext_idx) + 1

ext_resource = '[ext_resource type="Script" uid="uid://xmov12" path="res://systems/enemy/enemy_movement.gd" id="X_move"]\n'
content = content[:end_of_last_ext] + ext_resource + content[end_of_last_ext:]

# Add EnemyMovement node before EnemyAI
# We'll just replace the EnemyAI node declaration with EnemyMovement + updated EnemyAI
ai_idx = content.find('[node name="EnemyAI"')

new_nodes = """[node name="EnemyMovement" type="Node" parent="." unique_id=987654330 node_paths=PackedStringArray("character_body")]
script = ExtResource("X_move")
character_body = NodePath("..")

[node name="EnemyAI" type="Node" parent="." unique_id=987654323 node_paths=PackedStringArray("sensor", "state_machine", "enemy_direction", "movement")]
script = ExtResource("X_ai")
sensor = NodePath("../EnemySensor")
state_machine = NodePath("../EnemyStateMachine")
enemy_direction = NodePath("../EnemyDirection")
movement = NodePath("../EnemyMovement")
enemy_data = ExtResource("5_edata")
"""

# Extract the old EnemyAI block
end_of_file = len(content)
old_ai_block = content[ai_idx:]
content = content[:ai_idx] + new_nodes

with open(file_path, "w") as f:
    f.write(content)
print("Patched successfully")
