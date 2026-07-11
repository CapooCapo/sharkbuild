import re

file_path = "/home/giahoang/dev/tinyGame/tinytinygame/scenes/enemy/enemy.tscn"
with open(file_path, "r") as f:
    content = f.read()

# Check if already patched
if "EnemySensor" in content and "EnemyAI" in content:
    print("Already patched")
    exit(0)

# Add ext_resources
last_ext_idx = content.rfind("[ext_resource")
end_of_last_ext = content.find("\n", last_ext_idx) + 1

ext_resources = """[ext_resource type="Script" uid="uid://cxab32sd" path="res://systems/enemy/enemy_sensor.gd" id="X_sensor"]
[ext_resource type="Script" uid="uid://cycd45sf" path="res://systems/enemy/enemy_ai.gd" id="X_ai"]
"""

content = content[:end_of_last_ext] + ext_resources + content[end_of_last_ext:]

# Add sub_resource for circle
first_sub_idx = content.find("[sub_resource")

sub_resources = """[sub_resource type="CircleShape2D" id="CircleShape2D_sensor"]
radius = 160.0

"""

content = content[:first_sub_idx] + sub_resources + content[first_sub_idx:]


# Add nodes at the end
nodes = """
[node name="EnemySensor" type="Area2D" parent="." unique_id=987654321]
collision_layer = 0
collision_mask = 4
script = ExtResource("X_sensor")
enemy_data = ExtResource("5_edata")

[node name="CollisionShape2D" type="CollisionShape2D" parent="EnemySensor" unique_id=987654322]
shape = SubResource("CircleShape2D_sensor")

[node name="EnemyAI" type="Node" parent="." unique_id=987654323 node_paths=PackedStringArray("sensor", "state_machine", "enemy_direction")]
script = ExtResource("X_ai")
sensor = NodePath("../EnemySensor")
state_machine = NodePath("../EnemyStateMachine")
enemy_direction = NodePath("../EnemyDirection")
"""

content += nodes

with open(file_path, "w") as f:
    f.write(content)
print("Patched successfully")
