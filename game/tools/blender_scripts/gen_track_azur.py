"""
Blender 5.0+ headless: generate Circuit Azur (Monaco-inspired) track mesh.
Narrow street circuit, 12m wide, ~3.3km.
Run: blender --background --python gen_track_azur.py
"""
import bpy
import math
import os
import sys

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "../../tracks/track_01_street/meshes/")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# 2D waypoints (x, z) for Circuit Azur — Monaco-inspired
# Manually placed key points forming a tight street circuit
WAYPOINTS_2D = [
    (0, 0),       # Start/Finish
    (80, -20),    # Sainte Devote right
    (100, -60),   # Beau Rivage climb
    (80, -120),   # Massenet
    (40, -160),   # Casino Square
    (-20, -180),  # Mirabeau Haute
    (-60, -200),  # Mirabeau Bas
    (-80, -240),  # Portier
    (-90, -310),  # Tunnel entry
    (-100, -380), # Tunnel exit
    (-80, -430),  # Nouvelle Chicane 1
    (-40, -450),  # Nouvelle Chicane 2
    (0, -440),    # Tabac
    (50, -420),   # Swimming Pool S1
    (80, -380),   # Swimming Pool S2
    (100, -330),  # Rascasse
    (80, -280),   # Anthony Noghes
    (40, -240),   # Start loop back
    (0, -180),
    (-20, -120),
    (0, -60),
    (0, 0),       # Close loop
]

TRACK_WIDTH = 12.0
BARRIER_HEIGHT = 1.2
BARRIER_THICKNESS = 0.3


def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()


def create_track_surface(waypoints, width, name="TrackSurface"):
    """Extrude a ribbon from waypoints to form the driveable surface."""
    import mathutils
    verts = []
    faces = []

    pts3 = [mathutils.Vector((x, 0.0, z)) for x, z in waypoints]

    for i in range(len(pts3) - 1):
        p0 = pts3[i]
        p1 = pts3[i + 1]
        direction = (p1 - p0).normalized()
        # Perpendicular in XZ plane
        perp = mathutils.Vector((-direction.z, 0, direction.x)).normalized()
        left0  = p0 + perp * (width / 2)
        right0 = p0 - perp * (width / 2)
        left1  = p1 + perp * (width / 2)
        right1 = p1 - perp * (width / 2)

        base = len(verts)
        verts.extend([left0, right0, right1, left1])
        faces.append((base, base+1, base+2, base+3))

    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.scene.collection.objects.link(obj)

    # Asphalt material
    mat = bpy.data.materials.new("Asphalt")
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (0.1, 0.1, 0.1, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.85
    obj.data.materials.append(mat)
    return obj


def create_barriers(waypoints, width, name="Barriers"):
    """Simple box barriers along both sides of the track."""
    import mathutils
    pts3 = [mathutils.Vector((x, 0.0, z)) for x, z in waypoints]

    barrier_mat = bpy.data.materials.new("Barrier")
    barrier_mat.use_nodes = True
    bsdf = barrier_mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (0.9, 0.9, 0.9, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.7

    for i in range(len(pts3) - 1):
        p0 = pts3[i]
        p1 = pts3[i + 1]
        mid = (p0 + p1) / 2
        seg_len = (p1 - p0).length
        direction = (p1 - p0).normalized()
        perp = mathutils.Vector((-direction.z, 0, direction.x)).normalized()
        angle = math.atan2(direction.z, direction.x)

        for side in (-1, 1):
            offset = perp * (width / 2 + BARRIER_THICKNESS / 2) * side
            loc = mid + offset + mathutils.Vector((0, BARRIER_HEIGHT / 2, 0))
            bpy.ops.mesh.primitive_cube_add(size=1, location=(loc.x, loc.y, loc.z))
            bar = bpy.context.active_object
            bar.name = f"Barrier_S{'+' if side > 0 else '-'}_{i}"
            bar.scale = (BARRIER_THICKNESS, BARRIER_HEIGHT, seg_len + 0.1)
            bar.rotation_euler = (0, angle, 0)
            bpy.ops.object.transform_apply(scale=True)
            bar.data.materials.append(barrier_mat)

    # Join all barrier objects
    bpy.ops.object.select_all(action='DESELECT')
    for obj in bpy.context.scene.objects:
        if obj.name.startswith("Barrier_"):
            obj.select_set(True)
    if bpy.context.selected_objects:
        bpy.context.view_layer.objects.active = bpy.context.selected_objects[0]
        bpy.ops.object.join()
        bpy.context.active_object.name = name
    return bpy.context.active_object


def export_glb(obj, filepath):
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.export_scene.gltf(
        filepath=filepath,
        export_format='GLB',
        use_selection=True,
        export_normals=True,
    )
    print(f"[gen_track_azur] Exported: {filepath}")


def build():
    clear_scene()

    surface = create_track_surface(WAYPOINTS_2D, TRACK_WIDTH)
    export_glb(surface, os.path.join(OUTPUT_DIR, "track_surface.glb"))

    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()

    barriers = create_barriers(WAYPOINTS_2D, TRACK_WIDTH)
    if barriers:
        export_glb(barriers, os.path.join(OUTPUT_DIR, "barriers.glb"))

    print("[gen_track_azur] Done.")


if __name__ == "__main__":
    build()
