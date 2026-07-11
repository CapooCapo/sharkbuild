import os
import re

def audit_project(root_dir):
    missing_files = []
    tscn_files = []
    gd_files = []
    for dirpath, _, filenames in os.walk(root_dir):
        if '.git' in dirpath or '.godot' in dirpath:
            continue
        for filename in filenames:
            ext = os.path.splitext(filename)[1]
            filepath = os.path.join(dirpath, filename)
            if ext == '.tscn':
                tscn_files.append(filepath)
            elif ext == '.gd':
                gd_files.append(filepath)

    res_regex = re.compile(r'path="res://([^"]+)"')
    
    print("=== Checking TSCN External Resources ===")
    for tscn in tscn_files:
        with open(tscn, 'r') as f:
            content = f.read()
            matches = res_regex.findall(content)
            for m in matches:
                full_path = os.path.join(root_dir, m)
                if not os.path.exists(full_path):
                    print(f"Broken resource in {tscn}: res://{m}")
                    
    print("\n=== Checking GDScript Preloads/Loads ===")
    preload_regex = re.compile(r'preload\("res://([^"]+)"\)')
    load_regex = re.compile(r'load\("res://([^"]+)"\)')
    for gd in gd_files:
        with open(gd, 'r') as f:
            content = f.read()
            for regex in [preload_regex, load_regex]:
                for m in regex.findall(content):
                    full_path = os.path.join(root_dir, m)
                    if not os.path.exists(full_path):
                        print(f"Broken load in {gd}: res://{m}")

if __name__ == "__main__":
    audit_project(".")
