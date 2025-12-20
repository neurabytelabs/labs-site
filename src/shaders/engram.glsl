/**
 * ENGRAM MEMORY - Neural Library
 * A vast crystalline library floating in neural space
 * Memories as glowing geometric shards, organized in impossible architecture
 *
 * Visual: Inception library meets crystalline data structures
 * Palette: Memory Cyan, Recall Violet, Nostalgia Pink, Insight Gold
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
const vec3 MEMORY_CYAN = vec3(0.02, 0.71, 0.83);
const vec3 RECALL_VIOLET = vec3(0.55, 0.36, 0.96);
const vec3 NOSTALGIA_PINK = vec3(0.94, 0.67, 0.99);
const vec3 INSIGHT_GOLD = vec3(0.98, 0.75, 0.14);
const vec3 MIND_SLATE = vec3(0.06, 0.09, 0.16);

// Noise
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
    for(int i = 0; i < 4; i++) {
        value += amplitude * noise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

// Crystal shard shape (diamond/icosahedron projection)
float crystalShard(vec2 uv, vec2 pos, float size, float rotation) {
    vec2 p = uv - pos;

    // Rotate
    float c = cos(rotation);
    float s = sin(rotation);
    p = vec2(p.x * c - p.y * s, p.x * s + p.y * c);

    // Diamond shape with aspect ratio
    p *= vec2(1.0, 1.5);
    float d = abs(p.x) + abs(p.y);

    // Sharp edges
    float crystal = smoothstep(size, size * 0.7, d);

    // Internal structure lines
    float internal = smoothstep(0.003, 0.0, abs(p.x)) * step(abs(p.y), size * 0.5);
    internal += smoothstep(0.003, 0.0, abs(p.y)) * step(abs(p.x), size * 0.3);
    internal += smoothstep(0.003, 0.0, abs(p.x + p.y * 0.5)) * 0.5;
    internal += smoothstep(0.003, 0.0, abs(p.x - p.y * 0.5)) * 0.5;

    // Edge highlight (fresnel-like)
    float edge = smoothstep(size * 0.8, size, d) - smoothstep(size, size * 1.2, d);

    return crystal + internal * crystal * 0.3 + edge * 0.5;
}

// Memory shard with glow
float memoryShard(vec2 uv, vec2 pos, float size, float rotation, float recall) {
    float shard = crystalShard(uv, pos, size, rotation);

    // Recall glow (brighter when "remembered")
    float dist = length(uv - pos);
    float glow = exp(-dist * 20.0) * recall;

    return shard + glow * 0.5;
}

// Infinite corridor illusion (memory palace)
float infiniteCorridor(vec2 uv, float t) {
    float corridor = 0.0;

    // Repeating archways receding into distance
    for(int i = 0; i < 8; i++) {
        float depth = float(i) * 0.08;
        float scale = 1.0 / (1.0 + depth * 3.0);

        vec2 archUV = uv * scale;

        // Arch shape
        float archWidth = 0.3 * scale;
        float archHeight = 0.4 * scale;

        // Vertical pillars
        float pillar = smoothstep(0.02 * scale, 0.0, abs(abs(archUV.x) - archWidth));
        pillar *= step(-archHeight, archUV.y) * step(archUV.y, archHeight);

        // Arch top
        float archTop = smoothstep(0.02 * scale, 0.0, abs(length(vec2(archUV.x, archUV.y - archHeight * 0.5)) - archWidth));
        archTop *= step(archHeight * 0.5, archUV.y);

        float alpha = 1.0 - depth * 1.5;
        corridor += (pillar + archTop) * alpha * 0.1;
    }

    return corridor;
}

// Synaptic connection threads
float synapticThreads(vec2 uv, float t) {
    float threads = 0.0;

    for(int i = 0; i < 12; i++) {
        float seed = float(i) * 5.77;

        // Catenary curve (hanging thread)
        float startX = (hash(vec2(seed, 0.0)) - 0.5) * 0.8;
        float endX = (hash(vec2(0.0, seed)) - 0.5) * 0.8;
        float sag = 0.1 + hash(vec2(seed, seed)) * 0.1;

        float normalizedX = (uv.x - startX) / (endX - startX);
        if(normalizedX > 0.0 && normalizedX < 1.0) {
            // Catenary approximation
            float catenaryY = sag * (cosh((normalizedX - 0.5) * 4.0) - 1.0) / (cosh(2.0) - 1.0);
            float expectedY = mix(-0.3, 0.3, hash(vec2(seed, 1.0))) - catenaryY;

            float dist = abs(uv.y - expectedY);
            float thread = smoothstep(0.008, 0.0, dist);

            // Pulse along thread
            float pulse = sin(normalizedX * 10.0 - t * 3.0 + seed) * 0.5 + 0.5;
            threads += thread * 0.15 * pulse;
        }
    }

    return threads;
}

// Floating memory shards
vec3 floatingShards(vec2 uv, float t) {
    vec3 shardColor = vec3(0.0);

    for(int i = 0; i < 12; i++) {
        float seed = float(i) * 3.33;

        // Lazy orbital motion
        float orbitSpeed = 0.1 + hash(vec2(seed, 0.0)) * 0.15;
        float orbitRadius = 0.15 + hash(vec2(0.0, seed)) * 0.2;
        float phase = seed * PHI;

        vec2 pos = vec2(
            sin(t * orbitSpeed + phase) * orbitRadius,
            cos(t * orbitSpeed * 0.7 + phase) * orbitRadius * 0.8
        );

        // Add vertical bob
        pos.y += sin(t * 0.5 + seed) * 0.03;

        float size = 0.03 + hash(vec2(seed, seed)) * 0.02;
        float rotation = t * 0.3 + seed;

        // Recall flash (occasional bright flash)
        float recallCycle = mod(t * 0.2 + seed * 0.5, 3.0);
        float recall = smoothstep(0.0, 0.1, recallCycle) * smoothstep(0.3, 0.1, recallCycle);

        float shard = memoryShard(uv, pos, size, rotation, recall);

        // Color based on shard index
        vec3 color;
        int colorIdx = int(mod(float(i), 4.0));
        if(colorIdx == 0) color = MEMORY_CYAN;
        else if(colorIdx == 1) color = RECALL_VIOLET;
        else if(colorIdx == 2) color = NOSTALGIA_PINK;
        else color = INSIGHT_GOLD;

        // Brighten on recall
        color = mix(color, vec3(1.0), recall * 0.5);

        shardColor += color * shard * (0.5 + recall * 0.5);
    }

    return shardColor;
}

// Thought dust particles
float thoughtDust(vec2 uv, float t) {
    float dust = 0.0;

    for(int i = 0; i < 30; i++) {
        float seed = float(i) * 7.77;

        vec2 pos = vec2(
            hash(vec2(seed, 0.0)) - 0.5,
            hash(vec2(0.0, seed)) - 0.5
        );

        // Gentle drift
        pos += vec2(
            sin(t * 0.3 + seed) * 0.05,
            cos(t * 0.2 + seed * 0.7) * 0.05
        );

        float dist = length(uv - pos);
        float particle = exp(-dist * 60.0);

        // Twinkle
        float twinkle = sin(t * 3.0 + seed * 10.0) * 0.5 + 0.5;
        dust += particle * 0.15 * twinkle;
    }

    return dust;
}

// Memory recall wave (when accessing memory)
float recallWave(vec2 uv, float t) {
    float wave = 0.0;

    // Concentric waves from recent recall points
    for(int i = 0; i < 3; i++) {
        float seed = float(i) * 11.11;
        float waveTime = mod(t * 0.5 + seed, 4.0);

        vec2 origin = vec2(
            sin(seed) * 0.2,
            cos(seed * PHI) * 0.15
        );

        float dist = length(uv - origin);
        float radius = waveTime * 0.2;

        float ring = smoothstep(0.02, 0.0, abs(dist - radius));
        ring *= smoothstep(4.0, 0.0, waveTime); // Fade out

        wave += ring * 0.3;
    }

    return wave;
}

void main() {
    vec2 uv = vUv - 0.5;
    float t = uTime;

    // Background - mind slate with depth
    vec3 color = MIND_SLATE;
    color += fbm(uv * 3.0 + t * 0.05) * 0.05;

    // Infinite corridor (very subtle, in background)
    float corridor = infiniteCorridor(uv, t);
    color += RECALL_VIOLET * corridor * 0.3;

    // Synaptic threads
    float threads = synapticThreads(uv, t);
    color += NOSTALGIA_PINK * threads;

    // Memory recall waves
    float wave = recallWave(uv, t);
    color += MEMORY_CYAN * wave;

    // Floating memory shards
    vec3 shards = floatingShards(uv, t);
    color += shards * (0.7 + uHover * 0.3);

    // Thought dust
    float dust = thoughtDust(uv, t);
    color += mix(MEMORY_CYAN, NOSTALGIA_PINK, 0.5) * dust;

    // Central memory core
    float coreDist = length(uv);
    float core = exp(-coreDist * 10.0) * 0.3;
    color += INSIGHT_GOLD * core;

    // Inner sanctum glow
    float innerGlow = smoothstep(0.2, 0.0, coreDist);
    color += mix(MEMORY_CYAN, vec3(1.0), innerGlow * 0.3) * innerGlow * 0.2;

    // Vignette
    float vignette = 1.0 - coreDist * 0.6;
    color *= vignette;

    // Tone mapping
    color = color / (1.0 + color);
    color = pow(color, vec3(0.95));

    gl_FragColor = vec4(color, 1.0);
}
