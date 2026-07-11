extends SceneTree

func _init() -> void:
    var player = CharacterBody2D.new()
    player.name = "Player"
    player.collision_layer = 1
    player.collision_mask = 1
    
    var player_col = CollisionShape2D.new()
    var player_shape = CircleShape2D.new()
    player_shape.radius = 10
    player_col.shape = player_shape
    player.add_child(player_col)
    
    var enemy_sensor = Area2D.new()
    enemy_sensor.name = "EnemySensor"
    enemy_sensor.collision_layer = 0
    enemy_sensor.collision_mask = 4  # The bug!
    
    var sensor_col = CollisionShape2D.new()
    var sensor_shape = CircleShape2D.new()
    sensor_shape.radius = 160
    sensor_col.shape = sensor_shape
    enemy_sensor.add_child(sensor_col)
    
    var root = Node2D.new()
    root.add_child(player)
    root.add_child(enemy_sensor)
    root.add_to_group("root")
    
    enemy_sensor.body_entered.connect(func(body): print("Stage 2: body_entered fired for ", body.name))
    
    # We need to add it to the scene tree to get physics
    var scene = PackedScene.new()
    scene.pack(root)
    ResourceSaver.save(scene, "res://test_physics.tscn")
    
    print("Stage 1: EnemySensor READY")
    quit()
