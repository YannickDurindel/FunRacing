"""
Blender 5.0+ headless script: generate a stylised F1 car body .glb
Run: blender --background --python gen_f1_car.py
"""
import bpy
import math
import os

OUTPUT_PATH = os.path.join(os.path.dirname(__file__), "../../cars/player_car/meshes/f1_car.glb")


def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    for col in bpy.data.collections:
        bpy.data.collections.remove(col)


def create_material(name, color, metallic=0.0, roughness=0.5):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    return mat


def add_mesh(name, verts, edges, faces, collection=None):
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(verts, edges, faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    col = collection or bpy.context.scene.collection
    col.objects.link(obj)
    return obj


def build_car():
    clear_scene()

    car_mat = create_material("CarPaint", (0.05, 0.25, 0.8), metallic=0.9, roughness=0.1)
    carbon_mat = create_material("Carbon", (0.05, 0.05, 0.05), metallic=0.2, roughness=0.4)
    tire_mat = create_material("Tire", (0.06, 0.06, 0.06), metallic=0.0, roughness=0.9)

    # ── Main body (monocoque) ──────────────────────────────────────────────────
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.3))
    body = bpy.context.active_object
    body.name = "Body"
    body.scale = (0.9, 2.1, 0.28)
    bpy.ops.object.transform_apply(scale=True)
    body.data.materials.append(car_mat)

    # ── Nose cone ──────────────────────────────────────────────────────────────
    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=0.35, radius2=0.08, depth=1.2,
                                    location=(0, 2.5, 0.22))
    nose = bpy.context.active_object
    nose.name = "Nose"
    nose.rotation_euler = (math.pi / 2, 0, 0)
    nose.data.materials.append(car_mat)

    # ── Cockpit surround (halo) ────────────────────────────────────────────────
    bpy.ops.mesh.primitive_torus_add(major_radius=0.38, minor_radius=0.06,
                                      location=(0, 0.1, 0.65))
    halo = bpy.context.active_object
    halo.name = "Halo"
    halo.scale.y = 1.6
    halo.data.materials.append(carbon_mat)

    # ── Front wing ────────────────────────────────────────────────────────────
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 2.9, 0.08))
    fw = bpy.context.active_object
    fw.name = "FrontWing"
    fw.scale = (1.6, 0.08, 0.06)
    bpy.ops.object.transform_apply(scale=True)
    fw.data.materials.append(carbon_mat)

    # Front wing end plates
    for side in (-1, 1):
        bpy.ops.mesh.primitive_cube_add(size=1, location=(side * 0.85, 2.9, 0.12))
        ep = bpy.context.active_object
        ep.name = f"FW_EndPlate_{'+' if side > 0 else '-'}"
        ep.scale = (0.04, 0.12, 0.1)
        bpy.ops.object.transform_apply(scale=True)
        ep.data.materials.append(carbon_mat)

    # ── Rear wing (two elements) ───────────────────────────────────────────────
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, -2.1, 0.95))
    rw_main = bpy.context.active_object
    rw_main.name = "RearWingMain"
    rw_main.scale = (1.1, 0.06, 0.12)
    bpy.ops.object.transform_apply(scale=True)
    rw_main.data.materials.append(carbon_mat)

    # DRS flap (separate mesh for animation)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, -2.06, 1.08))
    rw_drs = bpy.context.active_object
    rw_drs.name = "DRSFlap"
    rw_drs.scale = (1.1, 0.04, 0.08)
    bpy.ops.object.transform_apply(scale=True)
    rw_drs.data.materials.append(carbon_mat)

    # Rear wing pillars
    for side in (-1, 1):
        bpy.ops.mesh.primitive_cube_add(size=1, location=(side * 0.55, -2.1, 0.75))
        pillar = bpy.context.active_object
        pillar.name = f"RW_Pillar_{'+' if side > 0 else '-'}"
        pillar.scale = (0.04, 0.06, 0.22)
        bpy.ops.object.transform_apply(scale=True)
        pillar.data.materials.append(carbon_mat)

    # ── Sidepods ──────────────────────────────────────────────────────────────
    for side in (-1, 1):
        bpy.ops.mesh.primitive_cube_add(size=1, location=(side * 0.72, 0, 0.2))
        pod = bpy.context.active_object
        pod.name = f"Sidepod_{'+' if side > 0 else '-'}"
        pod.scale = (0.22, 1.4, 0.18)
        bpy.ops.object.transform_apply(scale=True)
        pod.data.materials.append(car_mat)

    # ── Wheels ────────────────────────────────────────────────────────────────
    wheel_positions = [
        (-0.85, 1.4, 0.0),
        ( 0.85, 1.4, 0.0),
        (-0.85, -1.4, 0.0),
        ( 0.85, -1.4, 0.0),
    ]
    for pos in wheel_positions:
        bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=0.33, depth=0.28,
                                             location=pos)
        wheel = bpy.context.active_object
        wheel.name = f"Wheel_{pos}"
        wheel.rotation_euler = (0, math.pi / 2, 0)
        wheel.data.materials.append(tire_mat)

    # ── Floor/diffuser ────────────────────────────────────────────────────────
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.02))
    floor_obj = bpy.context.active_object
    floor_obj.name = "Floor"
    floor_obj.scale = (1.0, 2.2, 0.02)
    bpy.ops.object.transform_apply(scale=True)
    floor_obj.data.materials.append(carbon_mat)

    # ── Export ────────────────────────────────────────────────────────────────
    bpy.ops.object.select_all(action='SELECT')
    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    bpy.ops.export_scene.gltf(
        filepath=OUTPUT_PATH,
        export_format='GLB',
        use_selection=True,
        export_normals=True,
    )
    print(f"[gen_f1_car] Exported: {OUTPUT_PATH}")


if __name__ == "__main__":
    build_car()
