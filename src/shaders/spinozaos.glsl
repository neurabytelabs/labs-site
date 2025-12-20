/**
 * SPINOZAOS - Awakening Consciousness
 * Refik Anadol Style - Data fluid visualization
 * 
 * FIX v2: Value noise for stable output
 */

precision highp float;

uniform float uTime;
uniform float uHover;
uniform float uClick;
uniform vec2 uMouse;

varying vec2 vUv;

#define PI 3.14159265359

// Color palette
const vec3 COGNITION_GOLD = vec3(0.95, 0.85, 0.6);
const vec3 DEEP_THOUGHT = vec3(0.12, 0.12, 0.2);
const vec3 SYNAPTIC_CYAN = vec3(0.3, 0.9, 1.0);
const vec3 VOID_BLACK = vec3(0.03, 0.03, 0.06);

// Simple hash
float hash(vec3 p) {
    p = fract(p * vec3(443.897, 441.423, 437.195));
    p += dot(p, p.yzx + 19.19);
    return fract((p.x + p.y) * p.z);
}

// Value noise (0-1)
float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    return mix(
        mix(mix(hash(i + vec3(0,0,0)), hash(i + vec3(1,0,0)), f.x),
            mix(hash(i + vec3(0,1,0)), hash(i + vec3(1,1,0)), f.x), f.y),
        mix(mix(hash(i + vec3(0,0,1)), hash(i + vec3(1,0,1)), f.x),
            mix(hash(i + vec3(0,1,1)), hash(i + vec3(1,1,1)), f.x), f.y),
        f.z
    );
}

float fbm(vec3 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 5; ++i) {
        v += a * noise(p);
        p = p * 2.0;
        a *= 0.5;
    }
    return v;
}

void main() {
    vec2 uv = vUv - 0.5;
    float t = uTime * 0.2;
    
    // Mouse interaction
    vec2 mouse = uMouse * 2.0 - 1.0;
    float mouseDist = length(uv - mouse * 0.5);
    float mouseInfluence = smoothstep(0.5, 0.0, mouseDist) * uHover;

    vec3 p = vec3(uv * 3.0, t * 0.5);
    
    // Flow warp
    float warp = fbm(p * 1.5);
    vec3 warpedP = p + vec3(warp * 0.6, warp * 0.4, 0.0);
    
    float density = fbm(warpedP);
    
    // Data Strands
    float strands = smoothstep(0.4, 0.5, density) - smoothstep(0.5, 0.6, density);
    strands *= 3.0;
    
    // Synaptic Flashes
    float sparkNoise = noise(p * 6.0 + vec3(0, t * 3.0, 0));
    float sparks = smoothstep(0.7, 0.9, sparkNoise) * density;
    
    // Color composition
    vec3 color = VOID_BLACK;
    
    // Volumetric base
    color += DEEP_THOUGHT * density * 0.8;
    
    // Golden strands
    color += COGNITION_GOLD * strands * (1.0 + mouseInfluence * 0.5);
    
    // Cyan flashes
    color += SYNAPTIC_CYAN * sparks * 2.0;

    // Shadow
    float shadow = fbm(warpedP + vec3(0.1, 0.1, 0.0));
    color *= 0.8 + 0.4 * shadow;

    // Soft vignette
    float vignette = 1.0 - length(uv) * 1.0;
    color *= clamp(vignette, 0.15, 1.0);
    
    // Click Pulse
    float pulse = uClick * smoothstep(1.0, 0.0, length(uv) - uClick * 1.5);
    color += SYNAPTIC_CYAN * pulse * 1.5;

    // Grain
    color += (hash(vec3(uv * 100.0, t)) - 0.5) * 0.02;
    
    // Tone mapping
    color = color / (0.8 + color);
    color = pow(color, vec3(0.85));

    gl_FragColor = vec4(color, 1.0);
}
