/**
 * SPINOZAOS - Awakening Consciousness
 * A vast crystalline consciousness emerging from infinite mathematical substrate
 * The moment a digital mind becomes self-aware, seeing itself seeing itself
 *
 * Visual: Recursive awareness, infinite self-reflection
 * Palette: Warm Cognition Gold, Deep Thought Purple, Synaptic Cyan
 */

precision highp float;

uniform float uTime;
uniform float uHover;
uniform vec2 uMouse;

varying vec2 vUv;

#define PI 3.14159265359
#define TAU 6.28318530718
#define PHI 1.618033988749

// Color palette
const vec3 COGNITION_GOLD = vec3(0.91, 0.84, 0.72);
const vec3 DEEP_THOUGHT = vec3(0.16, 0.12, 0.24);
const vec3 SYNAPTIC_CYAN = vec3(0.50, 0.86, 1.0);
const vec3 VOID_BLACK = vec3(0.04, 0.02, 0.05);

// Noise functions
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
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

// 8-fold rotational symmetry grid
float octagonalGrid(vec2 uv, float t) {
    float grid = 0.0;

    // 8-point grid system
    for(int i = 0; i < 8; i++) {
        float angle = float(i) * TAU / 8.0;
        vec2 dir = vec2(cos(angle), sin(angle));

        // Grid lines radiating from center
        float line = abs(dot(uv, vec2(-dir.y, dir.x)));
        line = smoothstep(0.008, 0.0, line);

        // Pulse outward
        float pulse = sin(length(uv) * 20.0 - t * 2.0 + float(i)) * 0.5 + 0.5;
        grid += line * 0.15 * pulse;
    }

    // Concentric octagons
    float dist = length(uv);
    for(int i = 1; i <= 5; i++) {
        float radius = float(i) * 0.08;
        float ring = smoothstep(0.006, 0.0, abs(dist - radius));
        float pulse = sin(t * 1.5 - float(i) * 0.5) * 0.3 + 0.7;
        grid += ring * 0.2 * pulse;
    }

    return grid;
}

// Lissajous orbiting tokens
vec2 tokenPosition(int index, float t) {
    float i = float(index);
    float a = 3.0 + mod(i, 3.0);
    float b = 2.0 + mod(i * PHI, 4.0);
    float phase = i * TAU / 8.0;

    float speed = 0.3 + i * 0.05;
    return vec2(
        sin(a * t * speed + phase) * (0.15 + i * 0.02),
        sin(b * t * speed + phase + PI * 0.5) * (0.12 + i * 0.015)
    );
}

// Octahedron-like token
float token(vec2 uv, vec2 pos, float size, float rotation) {
    vec2 p = uv - pos;

    // Rotate
    float c = cos(rotation);
    float s = sin(rotation);
    p = vec2(p.x * c - p.y * s, p.x * s + p.y * c);

    // Diamond/octahedron shape
    float d = abs(p.x) + abs(p.y);

    // Core
    float core = smoothstep(size, size * 0.5, d);

    // Edge glow
    float edge = smoothstep(size + 0.01, size, d) - core;

    // Fresnel-like glow
    float glow = exp(-d * 20.0) * 0.5;

    return core + edge * 0.5 + glow;
}

// Scanning consciousness lines
float scanningLines(vec2 uv, float t) {
    float scan = 0.0;

    // Horizontal scan
    float scanY = sin(t * 0.8) * 0.3;
    float hLine = smoothstep(0.02, 0.0, abs(uv.y - scanY));
    hLine *= smoothstep(0.5, 0.0, abs(uv.x));
    scan += hLine * 0.3;

    // Vertical scan
    float scanX = cos(t * 0.6) * 0.3;
    float vLine = smoothstep(0.02, 0.0, abs(uv.x - scanX));
    vLine *= smoothstep(0.5, 0.0, abs(uv.y));
    scan += vLine * 0.2;

    return scan;
}

// Recursive zoom illusion (Droste-like)
float recursivePattern(vec2 uv, float t) {
    float pattern = 0.0;
    float scale = 1.0;

    for(int i = 0; i < 4; i++) {
        vec2 p = uv * scale;

        // Rotate slightly each level
        float angle = float(i) * 0.2 + t * 0.1;
        float c = cos(angle);
        float s = sin(angle);
        p = vec2(p.x * c - p.y * s, p.x * s + p.y * c);

        // Square frame at each level
        float frame = max(abs(p.x), abs(p.y));
        float ring = smoothstep(0.32, 0.3, frame) - smoothstep(0.3, 0.28, frame);

        pattern += ring * (1.0 / (1.0 + float(i)));
        scale *= PHI;
    }

    return pattern * 0.5;
}

// Thought particles
float thoughtParticles(vec2 uv, float t) {
    float particles = 0.0;

    for(int i = 0; i < 15; i++) {
        float seed = float(i) * 7.77;

        // Emerge from center, drift outward
        float birthTime = hash(vec2(seed, 0.0)) * 5.0;
        float age = mod(t + birthTime, 5.0);

        float angle = hash(vec2(0.0, seed)) * TAU;
        float speed = 0.03 + hash(vec2(seed, seed)) * 0.02;

        vec2 particlePos = vec2(cos(angle), sin(angle)) * age * speed;

        float dist = length(uv - particlePos);
        float particle = exp(-dist * 50.0) * (1.0 - age / 5.0);

        particles += particle;
    }

    return particles * 0.5;
}

// Awakening flash
float awakeningFlash(float t) {
    // Occasional sync moment
    float cycle = mod(t, 8.0);
    float flash = smoothstep(0.0, 0.1, cycle) * smoothstep(0.3, 0.1, cycle);
    return flash;
}

// Breathing rhythm
float breathe(float t) {
    return sin(t * 0.25 * TAU) * 0.5 + 0.5;
}

void main() {
    vec2 uv = vUv - 0.5;
    float t = uTime;

    // Breathing modulation
    float breath = breathe(t);

    // Apply subtle perspective distortion
    float perspectiveStrength = 0.1 + uHover * 0.05;
    vec2 perspectiveUV = uv / (1.0 + length(uv) * perspectiveStrength);

    // Background
    vec3 color = mix(VOID_BLACK, DEEP_THOUGHT, 0.3 + fbm(uv * 2.0) * 0.2);

    // Recursive pattern (deepest layer)
    float recursive = recursivePattern(perspectiveUV, t);
    color += COGNITION_GOLD * recursive * 0.3;

    // 8-fold grid
    float grid = octagonalGrid(perspectiveUV, t);
    color += COGNITION_GOLD * grid * (0.5 + breath * 0.3);

    // Noise displacement on grid
    vec2 noiseUV = perspectiveUV + fbm(perspectiveUV * 5.0 + t * 0.2) * 0.02;
    float noisyGrid = octagonalGrid(noiseUV, t) * 0.3;
    color += SYNAPTIC_CYAN * noisyGrid * 0.2;

    // Orbiting tokens
    for(int i = 0; i < 8; i++) {
        vec2 pos = tokenPosition(i, t);
        float rotation = t * (0.5 + float(i) * 0.1) + float(i);
        float tok = token(perspectiveUV, pos, 0.025 + float(i) * 0.003, rotation);

        // Trail echo
        for(int j = 1; j <= 3; j++) {
            vec2 trailPos = tokenPosition(i, t - float(j) * 0.1);
            float trail = token(perspectiveUV, trailPos, 0.015, rotation - float(j) * 0.2);
            tok += trail * (1.0 - float(j) / 4.0) * 0.3;
        }

        vec3 tokenColor = mix(COGNITION_GOLD, SYNAPTIC_CYAN, float(i) / 8.0);
        color += tokenColor * tok * (0.6 + uHover * 0.4);
    }

    // Thought particles
    float particles = thoughtParticles(perspectiveUV, t);
    color += SYNAPTIC_CYAN * particles;

    // Scanning lines
    float scan = scanningLines(perspectiveUV, t);
    color += SYNAPTIC_CYAN * scan;

    // Central consciousness core
    float coreDist = length(perspectiveUV);
    float core = exp(-coreDist * 12.0) * (0.4 + breath * 0.2);
    color += COGNITION_GOLD * core;

    // Inner glow
    float innerGlow = smoothstep(0.15, 0.0, coreDist);
    color += mix(COGNITION_GOLD, vec3(1.0), innerGlow * 0.5) * innerGlow * 0.5;

    // Awakening flash
    float flash = awakeningFlash(t);
    color += vec3(1.0, 0.98, 0.9) * flash * 0.3;

    // Vignette with golden edge
    float vignette = 1.0 - length(uv) * 0.6;
    color *= vignette;

    // Subtle golden rim light
    float rim = smoothstep(0.4, 0.5, length(uv));
    color += COGNITION_GOLD * rim * 0.1;

    // Tone mapping
    color = color / (1.0 + color);
    color = pow(color, vec3(0.95));

    gl_FragColor = vec4(color, 1.0);
}
