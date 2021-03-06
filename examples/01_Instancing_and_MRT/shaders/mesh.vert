#version 330
#extension GL_ARB_gpu_shader5               : enable
#extension GL_ARB_shader_precision          : enable
#extension GL_ARB_texture_cube_map_array    : enable
#extension GL_ARB_separate_shader_objects   : enable
#extension GL_ARB_shading_language_420pack  : enable
#extension GL_ARB_shading_language_packing  : enable
#extension GL_ARB_explicit_uniform_location : enable
out gl_PerVertex { vec4 gl_Position; };

layout(location = 0) uniform int index;
layout(location = 1) uniform vec3 cam_pos;
layout(location = 2) uniform vec4 cam_rot;
layout(location = 3) uniform float fov_x;
layout(location = 4) uniform float fov_y;

layout(binding = 0) uniform samplerBuffer s_mesh;
layout(binding = 1) uniform samplerBuffer s_pos;

layout(location = 0) out vec3 pos;
layout(location = 1) out vec3 nor;
layout(location = 2) out vec2 uv;

vec3 v3rot(vec3 p, vec4 v) {
  return fma(cross(v.xyz, fma(p, vec3(v.w), cross(v.xyz, p))), vec3(2), p);
}

vec4 verneg(vec4 v) {
  return vec4(-v.xyz, v.w);
}

void main() {
  vec4 mesh_1 = texelFetch(s_mesh, gl_VertexID * 2 + 0);
  vec4 mesh_2 = texelFetch(s_mesh, gl_VertexID * 2 + 1);
  vec3 instance_pos = texelFetch(s_pos, gl_InstanceID).xyz;

  pos = mesh_1.xyz;
  nor = mesh_2.xyz;
  uv = vec2(mesh_1.w, mesh_2.w);

  pos += instance_pos;

  vec3 mv = pos;
  mv -= cam_pos;
  mv = v3rot(mv, verneg(cam_rot));

  mv.x *= fov_x;
  mv.y *= fov_y;

  mv.z *= -1;

  gl_Position = vec4(mv, mv.z + 0.1);
}