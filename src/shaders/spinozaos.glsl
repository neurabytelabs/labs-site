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
uniform vec2 uMouse;

varying vec2 vUv;

#define PI 3.14159265359
#define TAU 6.28318530718

// Color palette - SpinozaOS
const vec3 COGNITION_GOLD = vec3(0.91, 0.84, 0.72);
const vec3 DEEP_THOUGHT = vec3(0.16, 0.12, 0.24);
const vec3 SYNAPTIC_CYAN = vec3(0.50, 0.86, 1.0);
const vec3 VOID_BLACK = vec3(0.02, 0.01, 0.03); // Darker void

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
    vec3 shift = vec3(100.0);
    for (int i = 0; i < 5; ++i) {
        v += a * noise(p);
        p = p * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

// --- VISUALIZATION ---

void main() {
    vec2 uv = vUv - 0.5;
    
    // Correct aspect ratio mostly for circular shapes if needed, 
    // but full frame flow is better for this style.
    // float aspect = 1.0; // Assuming square for now based on card
    
    float t = uTime * 0.2; // Slow, majestic time
    
    // Mouse interaction - magnetic disturbance
    vec2 mouse = uMouse * 2.0 - 1.0; // -1 to 1
    float mouseDist = length(uv - mouse * 0.5); // *0.5 because uv is -0.5 to 0.5
    float mouseInfluence = smoothstep(0.4, 0.0, mouseDist) * uHover;

    // Coordinate space for flow
    vec3 p = vec3(uv * 3.0, t * 0.5);
    
    // 1. Base Flow Field (Large Scale)
    vec3 flow = curlNoise(p);
    
    // 2. Detail Flow (Small Scale)
    vec3 detailFlow = curlNoise(p * 2.0 + flow * 0.5);
    
    // Combine flows with mouse interaction
    vec3 finalFlow = mix(flow, detailFlow, 0.5);
    finalFlow += vec3(mouse, 0.0) * mouseInfluence * 2.0;

    // 3. Particle Density Simulation
    // Instead of rendering points, we render density fields warped by the flow
    float density = fbm(p + finalFlow * 2.0);
    
    // Sharpen density to create "strands" or "particles"
    float strands = smoothstep(0.4, 0.6, density) - smoothstep(0.6, 0.7, density);
    
    // 4. "Data Points" - bright spots
    float points = smoothstep(0.7, 0.9, noise(p * 10.0 + finalFlow * 5.0));
    
    // 5. Color Mapping
    vec3 color = VOID_BLACK;
    
    // Deep fluid base
    color += DEEP_THOUGHT * density * 0.8;
    
    // Flow lines (Gold)
    color += COGNITION_GOLD * strands * 0.6 * (1.0 + mouseInfluence);
    
    // Synaptic flashes (Cyan)
    color += SYNAPTIC_CYAN * points * 1.2 * sin(t * 5.0 + density * 10.0);

    // 6. Volumetric Lighting approximation
    // Fake a light source moving
    vec2 lightPos = vec2(sin(t), cos(t)) * 0.5;
    float light = 1.0 / (length(uv - lightPos) + 0.1);
    color += color * light * 0.2;

    // 7. Post-process: Vignette & Grain
    float vignette = 1.0 - length(uv) * 1.2;
    color *= clamp(vignette, 0.0, 1.0);
    
    // Subtle film grain
    float grain = hash33(vec3(uv, t)).x * 0.05;
    color += grain;
    
    // Contrast boost
    color = pow(color, vec3(1.2));

    gl_FragColor = vec4(color, 1.0);
}