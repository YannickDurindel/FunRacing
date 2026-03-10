"""
Blender 5.0+ headless: generate Veloce Nazionale (Monza-inspired).
40 waypoints, 16m wide, high-speed with 2 chicane sections.
Run: blender --background --python gen_track_veloce.py
"""
import bpy
import math
import os

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "../../tracks/track_03_highspeed/meshes/")
os.makedirs(OUTPUT_DIR, exist_ok=True)

TRACK_WIDTH = 16.0
BARRIER_HEIGHT = 1.0
BARRIER_THICKNESS = 0.5

# Monza-inspired: long straights, two chicanes, Lesmo curves, Parabolica
WAYPOINTS_2D = [
    (0, 0),           # Start/Finish straight
    (80, 0),
    (160, 0),
    (220, 0),         # Variante del Rettifilo (Chicane 1 entry)
    (240, 20),        # Chicane 1 left
    (230, 50),        # Chicane 1 right
    (220, 80),        # Variante exit
    (200, 130),       # Curva Grande
    (160, 180),
    (100, 220),       # Lesmo 1
    (50, 240),
    (-10, 240),       # Lesmo 2
    (-60, 220),
    (-100, 180),
    (-120, 120),      # Variante Ascari (Chicane 2 entry)
    (-110, 80),       # Chicane 2 left
    (-90, 50),        # Chicane 2 right
    (-80, 20),        # Ascari exit
    (-60, -40),       # Back straight
    (-20, -80),       # Parabolica entry
    (20, -100),
    (80, -100),       # Parabolica apex
    (140, -80),
    (180, -40),
    (200, 0),         # Parabolica exit → Start/Finish
    (0, 0),           # Close loop
]

# Upsample to 40 waypoints
def lerp_wps(wps, count):
    result = []
    seg = len(wps) - 1
    for i in range(count):
        frac = i / (count - 1) * seg
        lo = int(frac); hi = min(lo + 1, len(wps) - 1)
        t = frac - lo
        result.append((wps[lo][0]*(1-t)+wps[hi][0]*t, wps[lo][1]*(1-t)+wps[hi][1]*t))
    return result

WAYPOINTS_40 = lerp_wps(WAYPOINTS_2D, 40)


def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()


def create_track_surface(waypoints, width, name="TrackSurface"):
    import mathutils
    verts, faces = [], []
    pts3 = [mathutils.Vector((x, 0.0, z)) for x, z in waypoints]
    for i in range(len(pts3) - 1):
        p0, p1 = pts3[i], pts3[i+1]
        d = (p1 - p0).normalized()
        perp = mathutils.Vector((-d.z, 0, d.x)).normalized()
        b = len(verts)
        verts.extend([p0+perp*(width/2), p0-perp*(width/2), p1-perp*(width/2), p1+perp*(width/2)])
        faces.append((b, b+1, b+2, b+3))
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.scene.collection.objects.link(obj)
    mat = bpy.data.materials.new("AsphaltHighspeed")
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (0.11, 0.11, 0.11, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.80
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
    print(f"[gen_track_veloce] Exported: {filepath}")


def build():
    clear_scene()
    surface = create_track_surface(WAYPOINTS_40, TRACK_WIDTH)
    export_glb(surface, os.path.join(OUTPUT_DIR, "track_surface.glb"))
    print("[gen_track_veloce] Done.")


if __name__ == "__main__":
    build()
