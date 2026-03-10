"""
Blender 5.0+ headless: generate Harrowstone Park (Silverstone-inspired).
60 waypoints, 14m wide, mixed circuit.
Run: blender --background --python gen_track_harrowstone.py
"""
import bpy
import math
import os

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "../../tracks/track_02_mixed/meshes/")
os.makedirs(OUTPUT_DIR, exist_ok=True)

TRACK_WIDTH = 14.0
BARRIER_HEIGHT = 1.0
BARRIER_THICKNESS = 0.4

# Silverstone-inspired waypoints — wider flowing circuit, ~5.8km
WAYPOINTS_2D = [
    (0, 0),         # Abbey / Start/Finish
    (60, 10),
    (120, 30),       # Village
    (160, 80),
    (180, 140),      # The Loop
    (160, 200),
    (120, 240),
    (60, 260),       # Aintree
    (0, 250),
    (-60, 240),      # Wellington Straight
    (-120, 220),
    (-160, 180),     # Brooklands
    (-180, 120),
    (-180, 60),      # Luffield
    (-160, 0),
    (-120, -40),     # Woodcote
    (-80, -80),
    (-40, -100),     # Copse
    (0, -100),
    (40, -80),       # Maggotts
    (80, -40),
    (100, 0),        # Becketts
    (100, 60),
    (80, 120),       # Chapel
    (60, 160),
    (20, 200),       # Stowe
    (-20, 220),
    (-60, 200),      # Vale
    (-100, 160),
    (-120, 100),     # Club
    (-100, 40),
    (-60, 0),
    (-20, -20),      # Abbey straight
    (20, -20),
    (60, -10),
    (0, 0),          # Close loop
]

# Pad to 60 waypoints with interpolation
def interpolate_waypoints(wps, target_count):
    import numpy as np
    t_orig = list(range(len(wps)))
    t_new  = list(range(target_count))
    xs = [p[0] for p in wps]
    zs = [p[1] for p in wps]
    # Simple linear interp
    xs_new = [xs[0]] * target_count
    zs_new = [zs[0]] * target_count
    for i in range(target_count):
        frac = i / (target_count - 1) * (len(wps) - 1)
        lo = int(frac)
        hi = min(lo + 1, len(wps) - 1)
        t  = frac - lo
        xs_new[i] = xs[lo] * (1 - t) + xs[hi] * t
        zs_new[i] = zs[lo] * (1 - t) + zs[hi] * t
    return list(zip(xs_new, zs_new))

# Can't use numpy in Blender by default; use manual interp
def lerp_wps(wps, count):
    result = []
    seg_count = len(wps) - 1
    for i in range(count):
        frac = i / (count - 1) * seg_count
        lo = int(frac)
        hi = min(lo + 1, len(wps) - 1)
        t  = frac - lo
        x  = wps[lo][0] * (1 - t) + wps[hi][0] * t
        z  = wps[lo][1] * (1 - t) + wps[hi][1] * t
        result.append((x, z))
    return result

WAYPOINTS_60 = lerp_wps(WAYPOINTS_2D, 60)


def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()


def create_track_surface(waypoints, width, name="TrackSurface"):
    import mathutils
    verts = []
    faces = []
    pts3 = [mathutils.Vector((x, 0.0, z)) for x, z in waypoints]
    for i in range(len(pts3) - 1):
        p0, p1 = pts3[i], pts3[i + 1]
        direction = (p1 - p0).normalized()
        perp = mathutils.Vector((-direction.z, 0, direction.x)).normalized()
        base = len(verts)
        verts.extend([p0 + perp*(width/2), p0 - perp*(width/2),
                       p1 - perp*(width/2), p1 + perp*(width/2)])
        faces.append((base, base+1, base+2, base+3))
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.scene.collection.objects.link(obj)
    mat = bpy.data.materials.new("Asphalt")
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (0.12, 0.12, 0.12, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.82
    obj.data.materials.append(mat)
    return obj


def export_glb(obj, filepath):
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.export_scene.gltf(
        filepath=filepath, export_format='GLB',
        use_selection=True, export_normals=True,
    )
    print(f"[gen_track_harrowstone] Exported: {filepath}")


def build():
    clear_scene()
    surface = create_track_surface(WAYPOINTS_60, TRACK_WIDTH)
    export_glb(surface, os.path.join(OUTPUT_DIR, "track_surface.glb"))
    print("[gen_track_harrowstone] Done.")


if __name__ == "__main__":
    build()
