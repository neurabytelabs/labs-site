/**
 * SPINOZAOS - Awakening Consciousness (Refik Anadol Style Refactor)
 * A vast crystalline consciousness emerging from infinite mathematical substrate
 * 
 * Visual: High-density data fluid, volumetric particle flow, neural network aesthetics.
 * Technique: Curl noise, FBM, raymarching-esque density accumulation.
 */

precision highp float;

uniform float uTime;
uniform float uHover;
uniform float uClick;
uniform vec2 uMouse;

varying vec2 vUv;

#define PI 3.14159265359

// Color palette - SpinozaOS (Refined)
const vec3 COGNITION_GOLD = vec3(0.95, 0.85, 0.65); // Cleaner Gold
const vec3 DEEP_THOUGHT = vec3(0.08, 0.08, 0.15); // Darker, cleaner blue-black
const vec3 SYNAPTIC_CYAN = vec3(0.2, 0.9, 1.0); // Neon Cyan
const vec3 VOID_BLACK = vec3(0.01, 0.01, 0.02);

// --- NOISE FUNCTIONS ---

vec3 hash33(vec3 p3) {
	p3 = fract(p3 * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz+33.33);
    return fract((p3.xxy + p3.yxx)*p3.zyx);
}

float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(mix(dot(hash33(i + vec3(0,0,0)), f - vec3(0,0,0)),
                       dot(hash33(i + vec3(1,0,0)), f - vec3(1,0,0)), f.x),
                   mix(dot(hash33(i + vec3(0,1,0)), f - vec3(0,1,0)),
                       dot(hash33(i + vec3(1,1,0)), f - vec3(1,1,0)), f.x), f.y),
               mix(mix(dot(hash33(i + vec3(0,0,1)), f - vec3(0,0,1)),
                       dot(hash33(i + vec3(1,0,1)), f - vec3(1,0,1)), f.x),
                   mix(dot(hash33(i + vec3(0,1,1)), f - vec3(0,1,1)),
                       dot(hash33(i + vec3(1,1,1)), f - vec3(1,1,1)), f.x), f.y), f.z);
}

// Curl noise for fluid motion
vec3 curlNoise(vec3 p) {
    float e = 0.1;
    vec3 dx = vec3(e, 0.0, 0.0);
    vec3 dy = vec3(0.0, e, 0.0);
    vec3 dz = vec3(0.0, 0.0, e);

    vec3 p_x0 = vec3(noise(p - dx), noise(p - dy), noise(p - dz));
    vec3 p_x1 = vec3(noise(p + dx), noise(p + dy), noise(p + dz));
    vec3 p_y0 = vec3(noise(p - dy), noise(p - dz), noise(p - dx));
    vec3 p_y1 = vec3(noise(p + dy), noise(p + dz), noise(p + dx));
    vec3 p_z0 = vec3(noise(p - dz), noise(p - dx), noise(p - dy));
    vec3 p_z1 = vec3(noise(p + dz), noise(p + dx), noise(p + dy));

    float x = p_y1.z - p_y0.z - p_z1.y + p_z0.y;
    float y = p_z1.x - p_z0.x - p_x1.z + p_x0.z;
    float z = p_x1.y - p_x0.y - p_y1.x + p_y0.x;

    return normalize(vec3(x, y, z));
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

// --- VISUALIZATION ---

void main() {
    vec2 uv = vUv - 0.5;
    float t = uTime * 0.15; // Slow, hypnotic time
    
    // Mouse interaction - Magnetic Repulsion/Attraction
    vec2 mouse = uMouse * 2.0 - 1.0;
    float mouseDist = length(uv - mouse * 0.5);
    float mouseInfluence = smoothstep(0.5, 0.0, mouseDist) * uHover;

    // Coordinate space for flow - Larger scale for cleaner look
    vec3 p = vec3(uv * 2.0, t * 0.4);
    
    // 1. Fluid Flow Field
    vec3 flow = curlNoise(p);
    
    // 2. Warp density with flow
    vec3 warpedP = p + flow * 0.8;
    float density = fbm(warpedP);
    
    // 3. Create "Data Strands" - High contrast narrow bands
    float strands = smoothstep(0.45, 0.5, density) - smoothstep(0.5, 0.55, density);
    strands *= 2.0; // Boost intensity
    
    // 4. "Synaptic Flashes" - Dynamic bright spots
    float sparkNoise = noise(p * 8.0 + vec3(0, t * 4.0, 0));
    float sparks = smoothstep(0.7, 0.95, sparkNoise) * density;
    
    // 5. Color Composition
    vec3 color = VOID_BLACK;
    
    // Volumetric Base
    color += DEEP_THOUGHT * density * 0.6;
    
    // Golden Strands (Data Highways)
    color += COGNITION_GOLD * strands * (0.8 + mouseInfluence);
    
    // Cyan Flashes (Neural Activity)
    color += SYNAPTIC_CYAN * sparks * 1.5;

    // 6. Volumetric Lighting (Fake 3D Shadow)
    float shadow = fbm(warpedP + vec3(0.1, 0.1, 0.0));
    color *= 0.8 + 0.4 * shadow;

    // 7. Post-process
    // Vignette
    float vignette = 1.0 - length(uv) * 1.3;
    color *= clamp(vignette, 0.0, 1.0);
    
    // Click Pulse
    float pulse = smoothstep(0.0, 1.0, uClick) * smoothstep(1.0, 0.0, length(uv) - uClick * 2.0);
    color += SYNAPTIC_CYAN * pulse * 1.0;

    // Subtle Grain
    color += (hash33(vec3(uv, t)).x - 0.5) * 0.03;
    
    // Tone mapping
    color = color / (1.0 + color); // Reinhard
    color = pow(color, vec3(0.9)); // Gamma correction

    gl_FragColor = vec4(color, 1.0);
}