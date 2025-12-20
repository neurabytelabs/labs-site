/**
 * NEXUS AI FORGE - Creation Energy
 * A cosmic furnace where raw digital chaos is hammered into structured intelligence
 * Matter streams colliding, fusing, crystallizing into geometric perfection
 *
 * Visual: Generative data sculptures meets blacksmith mythology
 * Palette: Forge Fire Red, Molten Coral, Creation Gold, Transmutation Violet
 */

precision highp float;

uniform float uTime;
uniform float uHover;
uniform vec2 uMouse;

varying vec2 vUv;

#define PI 3.14159265359
#define TAU 6.28318530718

// Color palette
const vec3 FORGE_FIRE = vec3(1.0, 0.28, 0.34);
const vec3 MOLTEN_CORAL = vec3(1.0, 0.50, 0.31);
const vec3 CREATION_GOLD = vec3(1.0, 0.65, 0.01);
const vec3 TRANSMUTATION_VIOLET = vec3(0.44, 0.34, 0.89);
const vec3 ANVIL_BLACK = vec3(0.12, 0.12, 0.18);

// Noise functions
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float hash3(vec3 p) {
    return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    for(int i = 0; i < 5; i++) {
        value += amplitude * noise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

// Curl noise for swirling flow
vec2 curlNoise(vec2 p, float t) {
    float eps = 0.1;
    float n = fbm(p + t * 0.3);
    float dx = fbm(p + vec2(eps, 0.0) + t * 0.3) - n;
    float dy = fbm(p + vec2(0.0, eps) + t * 0.3) - n;
    return vec2(dy, -dx) * 5.0;
}

// Forge pulse rhythm - sharp attack, slow decay
float forgePulse(float t) {
    float cycle = fract(t * 0.6);
    return pow(1.0 - cycle, 4.0) + cycle * 0.2;
}

// Metaball-like molten mass
float moltenMass(vec2 uv, float t) {
    float d = 0.0;

    // Main forge core
    float core = 1.0 / (1.0 + length(uv) * 8.0);
    d += core;

    // Orbiting molten blobs
    for(int i = 0; i < 5; i++) {
        float angle = float(i) * TAU / 5.0 + t * (0.3 + float(i) * 0.1);
        float radius = 0.12 + sin(t * 2.0 + float(i)) * 0.03;
        vec2 blobPos = vec2(cos(angle), sin(angle)) * radius;
        float blob = 1.0 / (1.0 + length(uv - blobPos) * 15.0);
        d += blob * 0.6;
    }

    return d;
}

// Heat distortion
vec2 heatDistort(vec2 uv, float t) {
    float distort = sin(uv.y * 20.0 + t * 3.0) * 0.003;
    distort += sin(uv.x * 15.0 - t * 2.0) * 0.002;
    return vec2(distort, distort * 0.5);
}

// Particle inflow streams
float inflowStreams(vec2 uv, float t) {
    float streams = 0.0;

    for(int i = 0; i < 8; i++) {
        float angle = float(i) * TAU / 8.0;
        vec2 dir = vec2(cos(angle), sin(angle));

        // Curl the flow toward center
        vec2 flowUV = uv + curlNoise(uv * 2.0, t) * 0.02;

        // Stream line
        float perpDist = abs(dot(flowUV, vec2(-dir.y, dir.x)));
        float alongDist = dot(flowUV, dir);

        // Only show streams coming inward
        float stream = smoothstep(0.03, 0.0, perpDist);
        stream *= smoothstep(-0.5, 0.0, alongDist); // From edges
        stream *= smoothstep(0.0, 0.08, -alongDist); // Fade near center

        // Flowing particles along stream
        float flow = fract(alongDist * 10.0 + t * 2.0 + float(i) * 0.5);
        stream *= flow * flow;

        streams += stream * 0.3;
    }

    return streams;
}

// Sparks explosion
float sparks(vec2 uv, float t) {
    float s = 0.0;

    for(int i = 0; i < 20; i++) {
        float seed = float(i) * 7.33;
        float birthTime = hash(vec2(seed, 0.0)) * 3.0;
        float age = mod(t + birthTime, 3.0);

        if(age < 1.0) {
            float angle = hash(vec2(0.0, seed)) * TAU;
            float speed = 0.2 + hash(vec2(seed, seed)) * 0.3;
            vec2 vel = vec2(cos(angle), sin(angle)) * speed;

            // Spark position with gravity
            vec2 sparkPos = vel * age - vec2(0.0, age * age * 0.1);

            float dist = length(uv - sparkPos);
            float spark = exp(-dist * 60.0) * (1.0 - age);
            s += spark;
        }
    }

    return s;
}

// Crystallized output structures
float crystals(vec2 uv, float t) {
    float c = 0.0;

    for(int i = 0; i < 4; i++) {
        float seed = float(i) * 13.37;
        float birthTime = hash(vec2(seed, 1.0)) * 5.0;
        float age = mod(t + birthTime, 5.0);

        if(age > 1.0) {
            float angle = hash(vec2(1.0, seed)) * TAU;
            float dist = 0.15 + (age - 1.0) * 0.05;
            vec2 crystalPos = vec2(cos(angle), sin(angle)) * dist;

            // Diamond shape
            vec2 d = abs(uv - crystalPos);
            float diamond = d.x + d.y;
            float size = 0.02 + age * 0.005;
            float crystal = smoothstep(size + 0.005, size, diamond);

            // Cool color based on age
            c += crystal * min(1.0, (age - 1.0) * 0.5);
        }
    }

    return c;
}

// Color temperature mapping
vec3 forgeColor(float heat) {
    vec3 cold = TRANSMUTATION_VIOLET;
    vec3 warm = MOLTEN_CORAL;
    vec3 hot = CREATION_GOLD;
    vec3 white = vec3(1.0, 0.95, 0.9);

    if(heat < 0.33) {
        return mix(cold, warm, heat * 3.0);
    } else if(heat < 0.66) {
        return mix(warm, hot, (heat - 0.33) * 3.0);
    } else {
        return mix(hot, white, (heat - 0.66) * 3.0);
    }
}

void main() {
    vec2 uv = vUv - 0.5;
    float t = uTime;

    // Apply heat distortion
    vec2 distortedUV = uv + heatDistort(uv, t) * (1.0 + uHover);

    // Background - anvil darkness with heat shimmer
    vec3 color = ANVIL_BLACK;

    // Ember particles rising
    float embers = fbm(vec2(uv.x * 10.0, uv.y * 5.0 - t * 0.5)) * 0.1;
    embers *= smoothstep(-0.5, 0.0, uv.y); // More at bottom
    color += FORGE_FIRE * embers * 0.3;

    // Forge pulse
    float pulse = forgePulse(t);

    // Inflow streams
    float streams = inflowStreams(distortedUV, t);
    color += forgeColor(0.5) * streams;

    // Central molten mass
    float mass = moltenMass(distortedUV, t);
    float massIntensity = smoothstep(0.3, 1.5, mass);
    color += forgeColor(massIntensity * (0.7 + pulse * 0.3)) * massIntensity;

    // Core white-hot center
    float core = smoothstep(0.15, 0.0, length(distortedUV));
    color += vec3(1.0, 0.98, 0.95) * core * (0.5 + pulse * 0.5) * (1.0 + uHover * 0.5);

    // Sparks on forge strike
    float sparkIntensity = sparks(distortedUV, t) * pulse * 2.0;
    color += CREATION_GOLD * sparkIntensity;

    // Crystallized outputs (cooled creations)
    float crystal = crystals(distortedUV, t);
    color += TRANSMUTATION_VIOLET * crystal * 0.8;
    color += vec3(0.5, 0.7, 1.0) * crystal * 0.3; // Cool blue tint

    // Outer glow
    float outerGlow = exp(-length(uv) * 3.0) * 0.3;
    color += FORGE_FIRE * outerGlow * (0.5 + pulse * 0.3);

    // Flash on hover
    color += vec3(1.0, 0.9, 0.7) * uHover * pulse * 0.2;

    // Vignette
    float vignette = 1.0 - length(uv) * 0.5;
    color *= vignette;

    // Tone mapping
    color = color / (1.0 + color);
    color = pow(color, vec3(0.95));

    gl_FragColor = vec4(color, 1.0);
}
