/**
 * COGNITIVE BOARDROOM - Collective AI Intelligence
 * Five distinct neural galaxies orbiting a shared consciousness core
 * Thoughts visible as light streams merging, diverging, debating
 *
 * Visual: teamLab collective intelligence meets corporate neural network
 * Palette: Chairman Violet, CTO Cyan, CFO Gold, Ethics Coral, CMO Sky
 */

precision highp float;

uniform float uTime;
uniform float uHover;
uniform vec2 uMouse;

varying vec2 vUv;

#define PI 3.14159265359
#define TAU 6.28318530718
#define PHI 1.618033988749

// Color palette - 5 distinct personas
const vec3 CHAIRMAN_VIOLET = vec3(0.42, 0.36, 0.90);
const vec3 CTO_CYAN = vec3(0.0, 0.81, 0.79);
const vec3 CFO_GOLD = vec3(0.99, 0.80, 0.43);
const vec3 ETHICS_CORAL = vec3(0.88, 0.44, 0.33);
const vec3 CMO_SKY = vec3(0.46, 0.73, 1.0);
const vec3 BOARDROOM_VOID = vec3(0.05, 0.05, 0.12);

// Noise
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
    for(int i = 0; i < 4; i++) {
        value += amplitude * noise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

// Voronoi for CTO's pattern
float voronoi(vec2 p) {
    vec2 n = floor(p);
    vec2 f = fract(p);
    float m = 1.0;

    for(int i = -1; i <= 1; i++) {
        for(int j = -1; j <= 1; j++) {
            vec2 g = vec2(float(i), float(j));
            vec2 o = vec2(hash(n + g), hash((n + g) * 1.3));
            vec2 r = g + o - f;
            float d = dot(r, r);
            m = min(m, d);
        }
    }

    return sqrt(m);
}

// Get persona position in pentagon
vec2 getPersonaPosition(int index, float t) {
    float angle = float(index) * TAU / 5.0 - PI / 2.0; // Start from top
    float breathe = sin(t * 0.5 + float(index)) * 0.02;
    float radius = 0.28 + breathe;
    return vec2(cos(angle), sin(angle)) * radius;
}

// Get persona color
vec3 getPersonaColor(int index) {
    if(index == 0) return CHAIRMAN_VIOLET;
    if(index == 1) return CFO_GOLD;
    if(index == 2) return CTO_CYAN;
    if(index == 3) return ETHICS_CORAL;
    return CMO_SKY;
}

// Unique pattern per persona
float personaPattern(int id, vec2 uv, float t) {
    if(id == 0) { // Chairman - radiating authority waves
        float angle = atan(uv.y, uv.x);
        float r = length(uv);
        return sin(angle * 8.0 + r * 20.0 - t * 2.0) * 0.5 + 0.5;
    }
    if(id == 1) { // CFO - precise grid of numbers
        vec2 grid = fract(uv * 15.0);
        float dots = smoothstep(0.3, 0.2, length(grid - 0.5));
        return dots * (sin(t * 3.0 + uv.x * 10.0) * 0.5 + 0.5);
    }
    if(id == 2) { // CTO - voronoi tech cells
        return 1.0 - voronoi(uv * 8.0 + t * 0.5);
    }
    if(id == 3) { // Ethics - balanced yin-yang flow
        float angle = atan(uv.y, uv.x) + t * 0.5;
        return sin(angle * 2.0) * 0.5 + 0.5;
    }
    // CMO - dynamic marketing waves
    return fbm(uv * 5.0 + t * 0.3);
}

// Entity node with internal pattern
float entityNode(vec2 uv, vec2 pos, float radius, int id, float t, float isSpeaking) {
    vec2 localUV = uv - pos;
    float dist = length(localUV);

    // Core glow
    float core = exp(-dist * 15.0);

    // Inner pattern (visible inside the node)
    float pattern = personaPattern(id, localUV * 10.0, t);
    float patternMask = smoothstep(radius, radius * 0.3, dist);

    // Pulsing ring when speaking
    float ring = 0.0;
    if(isSpeaking > 0.5) {
        float pulse = sin(t * 6.0) * 0.5 + 0.5;
        ring = smoothstep(0.02, 0.0, abs(dist - radius * (1.2 + pulse * 0.3)));
        ring *= pulse;
    }

    // Outer aura
    float aura = smoothstep(radius * 2.0, radius, dist) * 0.3;

    return core + pattern * patternMask * 0.5 + ring + aura;
}

// Neural bridge connection between entities
float neuralBridge(vec2 uv, vec2 p1, vec2 p2, float t, float thickness, float flow) {
    vec2 dir = p2 - p1;
    float len = length(dir);
    dir /= len;

    vec2 perp = vec2(-dir.y, dir.x);
    vec2 toPoint = uv - p1;

    float along = dot(toPoint, dir);
    float across = dot(toPoint, perp);

    // Curved path using sine
    float curve = sin(along / len * PI) * 0.05;
    float adjustedAcross = across - curve;

    // Main bridge line
    float bridge = smoothstep(thickness, 0.0, abs(adjustedAcross));
    bridge *= smoothstep(0.0, 0.05, along) * smoothstep(len, len - 0.05, along);

    // Flowing particles along bridge
    float particles = 0.0;
    for(int i = 0; i < 5; i++) {
        float particlePos = fract(along / len + t * flow + float(i) * 0.2);
        float particle = smoothstep(0.02, 0.0, abs(along / len - particlePos));
        particle *= smoothstep(thickness * 2.0, 0.0, abs(adjustedAcross));
        particles += particle * (1.0 - particlePos) * 0.5;
    }

    return bridge * 0.3 + particles;
}

// Central nexus where ideas merge
float centralNexus(vec2 uv, float t) {
    float dist = length(uv);

    // Breathing core
    float breathe = sin(t * 0.3) * 0.02;
    float core = smoothstep(0.08 + breathe, 0.04 + breathe, dist);

    // Concentric rings
    float rings = 0.0;
    for(int i = 1; i <= 3; i++) {
        float radius = float(i) * 0.03 + breathe;
        float ring = smoothstep(0.008, 0.0, abs(dist - radius));
        float pulse = sin(t * 2.0 - float(i) * 0.8) * 0.3 + 0.7;
        rings += ring * pulse * 0.5;
    }

    // Central glow
    float glow = exp(-dist * 20.0) * 0.5;

    return core + rings + glow;
}

// Decision particles converging to center
float decisionParticles(vec2 uv, float t) {
    float particles = 0.0;

    for(int i = 0; i < 15; i++) {
        float seed = float(i) * 7.77;
        float birthTime = hash(vec2(seed, 0.0)) * 4.0;
        float age = mod(t + birthTime, 4.0);

        // Start from random persona, converge to center
        float startAngle = hash(vec2(0.0, seed)) * TAU;
        float startRadius = 0.35;

        vec2 startPos = vec2(cos(startAngle), sin(startAngle)) * startRadius;
        vec2 pos = mix(startPos, vec2(0.0), age / 4.0);

        float dist = length(uv - pos);
        float particle = exp(-dist * 50.0) * (1.0 - age / 4.0);

        particles += particle;
    }

    return particles * 0.5;
}

// Background data streams (shared knowledge)
float dataStreams(vec2 uv, float t) {
    float streams = 0.0;

    for(int i = 0; i < 10; i++) {
        float x = (hash(vec2(float(i), 0.0)) - 0.5) * 0.9;
        float speed = 0.3 + hash(vec2(0.0, float(i))) * 0.3;
        float y = fract(-t * speed + hash(vec2(float(i), float(i))) * 10.0) * 1.2 - 0.6;

        float dist = length(vec2(uv.x - x, uv.y - y));
        float stream = exp(-dist * 30.0) * 0.2;
        streams += stream;
    }

    return streams;
}

void main() {
    vec2 uv = vUv - 0.5;
    float t = uTime;

    // Determine which persona is speaking (cycles through)
    int speakingIdx = int(mod(t * 0.3, 5.0));

    // Background
    vec3 color = BOARDROOM_VOID;

    // Background data streams
    float streams = dataStreams(uv, t);
    color += vec3(0.2, 0.3, 0.4) * streams;

    // Central nexus
    float nexus = centralNexus(uv, t);
    color += vec3(1.0, 0.95, 0.9) * nexus * 0.6;

    // Decision particles
    float particles = decisionParticles(uv, t);
    color += vec3(0.8, 0.9, 1.0) * particles;

    // Neural bridges (connect all 5 in golden ratio spiral pattern)
    for(int i = 0; i < 5; i++) {
        int next = int(mod(float(i) + 2.0, 5.0)); // Connect to 2 nodes away (pentagon star)

        vec2 p1 = getPersonaPosition(i, t);
        vec2 p2 = getPersonaPosition(next, t);

        // Flow direction based on speaking
        float flowDir = (i == speakingIdx) ? 1.0 : -0.5;
        float thickness = (i == speakingIdx || next == speakingIdx) ? 0.015 : 0.008;

        float bridge = neuralBridge(uv, p1, p2, t, thickness, flowDir);
        vec3 bridgeColor = mix(getPersonaColor(i), getPersonaColor(next), 0.5);
        color += bridgeColor * bridge * (0.5 + uHover * 0.3);
    }

    // Adjacent connections (pentagon edges)
    for(int i = 0; i < 5; i++) {
        int next = int(mod(float(i) + 1.0, 5.0));

        vec2 p1 = getPersonaPosition(i, t);
        vec2 p2 = getPersonaPosition(next, t);

        float bridge = neuralBridge(uv, p1, p2, t, 0.005, 0.3);
        color += vec3(0.4, 0.4, 0.5) * bridge * 0.3;
    }

    // Entity nodes (personas)
    for(int i = 0; i < 5; i++) {
        vec2 pos = getPersonaPosition(i, t);
        float isSpeaking = (i == speakingIdx) ? 1.0 : 0.0;

        float entity = entityNode(uv, pos, 0.06, i, t, isSpeaking);
        vec3 entityColor = getPersonaColor(i);

        // Brighter when speaking
        float intensity = 0.6 + isSpeaking * 0.4 + uHover * 0.2;
        color += entityColor * entity * intensity;
    }

    // Thought ripples when speaking
    vec2 speakerPos = getPersonaPosition(speakingIdx, t);
    float rippleTime = fract(t * 0.5);
    float rippleRadius = rippleTime * 0.3;
    float ripple = smoothstep(0.02, 0.0, abs(length(uv - speakerPos) - rippleRadius));
    ripple *= (1.0 - rippleTime);
    color += getPersonaColor(speakingIdx) * ripple * 0.3;

    // Vignette
    float vignette = 1.0 - length(uv) * 0.5;
    color *= vignette;

    // Tone mapping
    color = color / (1.0 + color);
    color = pow(color, vec3(0.95));

    gl_FragColor = vec4(color, 1.0);
}
