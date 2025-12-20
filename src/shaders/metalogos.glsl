/**
 * META-LOGOS: The Cognitive Forge
 * Visual: Molten metal, heat distortion, industrial sparks, forging process.
 * Palette: Magma Orange, Obsidian Black, Steel Grey, White Heat.
 */

precision highp float;

uniform float uTime;
uniform float uHover;
uniform float uClick;
uniform vec2 uMouse;

varying vec2 vUv;

#define PI 3.14159265359

// Colors
const vec3 MAGMA_CORE = vec3(1.0, 0.3, 0.05);
const vec3 STEEL = vec3(0.5, 0.6, 0.7);
const vec3 OBSIDIAN = vec3(0.05, 0.05, 0.07);
const vec3 HEAT_WHITE = vec3(1.0, 0.95, 0.8);

// Noise functions
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

float fbm(vec3 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; ++i) {
        v += a * noise(p);
        p = p * 2.0;
        a *= 0.5;
    }
    return v;
}

// Heat distortion pattern
float heatHaze(vec2 uv, float t) {
    return fbm(vec3(uv * 5.0, t * 0.5)) * 0.5 + fbm(vec3(uv * 10.0 + vec2(0, t), t)) * 0.2;
}

// Spark particles
float sparks(vec2 uv, float t) {
    float s = 0.0;
    for(float i=0.0; i<10.0; i++) {
        vec3 p = hash33(vec3(i, 0.0, 0.0));
        float life = fract(t * (0.5 + p.z) + p.x);
        
        vec2 pos = vec2(p.x * 2.0 - 1.0, -1.0 + life * 2.5); // Rise up
        pos.x += sin(life * 10.0 + p.y * 10.0) * 0.1; // Wiggle
        
        float size = 0.01 * (1.0 - life);
        float d = length(uv - pos);
        s += smoothstep(size, size * 0.5, d) * (1.0 - life);
    }
    return s;
}

void main() {
    vec2 uv = vUv * 2.0 - 1.0; // -1 to 1
    float t = uTime;

    // Flowing molten metal background
    vec2 flow = vec2(t * 0.1, t * 0.2);
    float metal = fbm(vec3(uv * 2.0 + flow, t * 0.05));
    
    // Heat distortion from bottom
    float heat = heatHaze(uv * 0.5 + vec2(0, t * 0.2), t);
    
    // Core color mixing
    vec3 color = mix(OBSIDIAN, STEEL, metal * 0.5);
    
    // Molten veins
    float vein = smoothstep(0.4, 0.6, metal + heat * 0.3);
    color = mix(color, MAGMA_CORE, vein);
    
    // Hot spots
    float hotSpot = smoothstep(0.6, 0.8, metal + heat * 0.2 + uHover * 0.2);
    color = mix(color, HEAT_WHITE, hotSpot);
    
    // Sparks rising
    float sparkVal = sparks(uv, t * 1.5);
    color += vec3(1.0, 0.8, 0.4) * sparkVal * 2.0;

    // Interaction: Mouse heat
    float mouseDist = length(uv - (uMouse * 2.0 - 1.0));
    float mouseHeat = smoothstep(0.5, 0.0, mouseDist);
    color += MAGMA_CORE * mouseHeat * uHover * 0.5;

    // Click Pulse: Hammer strike
    float hammer = smoothstep(0.0, 1.0, uClick) * smoothstep(0.5, 0.0, length(uv));
    color += HEAT_WHITE * hammer * 3.0;
    
    // Vignette
    color *= 1.0 - length(uv * 0.5);

    gl_FragColor = vec4(color, 1.0);
}
