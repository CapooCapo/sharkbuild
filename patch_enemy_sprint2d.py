import re

file_path = "/home/giahoang/dev/tinyGame/tinytinygame/scenes/enemy/enemy.tscn"
with open(file_path, "r") as f:
    content = f.read()

# Check if EnemyKnockback is already in the file
if "EnemyKnockback" in content and "NavigationAgent2D" in content:
    print("Already patched")
    exit(0)

# Add ext_resource for enemy_knockback.gd
last_ext_idx = content.rfind("[ext_resource")
end_of_last_ext = content.find("\n", last_ext_idx) + 1

ext_resource = '[ext_resource type="Script" uid="uid://xknock456" path="res://systems/enemy/enemy_knockback.gd" id="X_knock"]\n'
content = content[:end_of_last_ext] + ext_resource + content[end_of_last_ext:]

# Replace EnemyMovement block
move_idx = content.find('[node name="EnemyMovement"')
end_move_idx = content.find('\n\n', move_idx)

new_move = """[node name="EnemyMovement" type="Node" parent="." unique_id=987654330 node_paths=PackedStringArray("character_body", "knockback", "nav_agent")]
script = ExtResource("X_move")
character_body = NodePath("..")
knockback = NodePath("../EnemyKnockback")
nav_agent = NodePath("../NavigationAgent2D")"""

content = content[:move_idx] + new_move + content[end_move_idx:]

# Add EnemyKnockback and NavigationAgent2D before EnemyCooldown
cool_idx = content.find('[node name="EnemyCooldown"')
new_nodes = """[node name="NavigationAgent2D" type="NavigationAgent2D" parent="." unique_id=987654340]

[node name="EnemyKnockback" type="Node" parent="." unique_id=987654341 node_paths=PackedStringArray("character_body")]
script = ExtResource("X_knock")
character_body = NodePath("..")\n\n"""

content = content[:cool_idx] + new_nodes + content[cool_idx:]

with open(file_path, "w") as f:
    f.write(content)
print("Patched successfully")
