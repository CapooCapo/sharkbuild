import time
import subprocess
import os

# Modify enemy_sensor to print
sensor_path = "systems/enemy/enemy_sensor.gd"
with open(sensor_path, "r") as f:
    orig_sensor = f.read()

new_sensor = orig_sensor.replace(
    "func _ready() -> void:", 
    "func _ready() -> void:\n\tprint(\"Stage 1: EnemySensor READY\")"
).replace(
    "func _on_body_entered(body: Node2D) -> void:",
    "func _on_body_entered(body: Node2D) -> void:\n\tprint(\"Stage 2: body_entered fired for \", body.name)\n\tprint(\"Stage 3: is in player group? \", body.is_in_group(\"player\"))"
)

with open(sensor_path, "w") as f:
    f.write(new_sensor)

proc = subprocess.Popen(["godot", "--headless", "--time-scale", "5"], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
time.sleep(3)
proc.terminate()
proc.wait()

with open(sensor_path, "w") as f:
    f.write(orig_sensor)

print(proc.stdout.read())
