/**
 * Shader Index - Centralized shader imports
 * Each shader is a GLSL fragment shader for project visualization
 */

import spinozaos from './spinozaos.glsl';
import metalogos from './metalogos.glsl';
import lithosphere from './lithosphere.glsl';
import boardroom from './boardroom.glsl';
import nexus from './nexus.glsl';
import oracle from './oracle.glsl';
import engram from './engram.glsl';
import manifesto from './manifesto.glsl';
import voice from './voice.glsl';

// Shared vertex shader for all cards
export const vertexShader = `
  varying vec2 vUv;
  void main() {
    vUv = uv;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
  }
`;

// Map project IDs to their shaders
export const shaders = {
  metalogos,
  spinozaos,
  lithosphere,
  boardroom,
  nexus,
  oracle,
  engram,
  manifesto,
  voice
};

export default shaders;
