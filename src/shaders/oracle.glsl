/**
 * ORACLE ENGINE - Probability Futures
 * Standing at the nexus of infinite timelines
 * Probability streams branching, merging, flowing into fractal futures
 *
 * Visual: Time as a visible dimension, Minority Report meets sacred geometry
 * Palette: Oracle Purple, Timeline Blue, Probability Green, Warning Amber
 */

precision highp float;

uniform float uTime;
uniform float uHover;
uniform vec2 uMouse;

varying vec2 vUv;

#define PI 3.14159265359
#define TAU 6.28318530718

// Color palette
const vec3 ORACLE_PURPLE = vec3(0.66, 0.33, 0.97);
const vec3 TIMELINE_BLUE = vec3(0.23, 0.51, 0.96);
const vec3 PROBABILITY_GREEN = vec3(0.06, 0.73, 0.51);
const vec3 WARNING_AMBER = vec3(0.96, 0.62, 0.04);
const vec3 TEMPORAL_VOID = vec3(0.01, 0.03, 0.05);

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

// Present moment orb
float presentMoment(vec2 uv, float t) {
    float dist = length(uv);

    // Breathing core
    float breathe = sin(t * 0.8) * 0.02;
    float core = smoothstep(0.08 + breathe, 0.05 + breathe, dist);

    // Pulsing rings
    float rings = 0.0;
    for(int i = 1; i <= 3; i++) {
        float radius = 0.05 + float(i) * 0.02 + breathe;
        float ring = smoothstep(0.008, 0.0, abs(dist - radius));
        float pulse = sin(t * 2.0 - float(i) * 0.5) * 0.3 + 0.7;
        rings += ring * pulse * 0.5;
    }

    // Glow
    float glow = exp(-dist * 15.0) * 0.5;

    return core + rings + glow;
}

// Timeline stream with branching
float timelineStream(vec2 uv, float seed, float t, out float probability) {
    float stream = 0.0;
    probability = 1.0;

    // Start from center, branch outward
    float y = uv.y;
    float x = uv.x;

    // Base path with slight curve
    float basePath = sin(seed * 10.0 + y * 3.0) * 0.1;

    // Branch points
    float branchY1 = 0.1 + hash(vec2(seed, 0.0)) * 0.1;
    float branchY2 = 0.25 + hash(vec2(seed, 1.0)) * 0.1;

    // Calculate which branch we're on
    float branchDir = 0.0;
    if(y > branchY1) {
        branchDir += (hash(vec2(seed, 2.0)) - 0.5) * 0.3;
        probability *= 0.7;
    }
    if(y > branchY2) {
        branchDir += (hash(vec2(seed, 3.0)) - 0.5) * 0.2;
        probability *= 0.5;
    }

    float expectedX = basePath + branchDir * (y - branchY1);

    // Stream width based on probability
    float width = 0.02 * probability + 0.005;
    stream = smoothstep(width, 0.0, abs(x - expectedX));

    // Flowing particles
    float flow = fract(y * 5.0 - t * 0.5 + seed);
    stream *= 0.5 + flow * 0.5;

    // Fade at edges
    stream *= smoothstep(0.0, 0.05, y);
    stream *= smoothstep(0.5, 0.35, y);

    return stream;
}

// Past echoes (ghostly backwards flow)
float pastEchoes(vec2 uv, float t) {
    float echoes = 0.0;

    // Reversed, desaturated streams
    for(int i = 0; i < 5; i++) {
        float seed = float(i) * 7.77;
        float angle = (float(i) - 2.0) * 0.3;

        vec2 rotUV = vec2(
            uv.x * cos(angle) - uv.y * sin(angle),
            uv.x * sin(angle) + uv.y * cos(angle)
        );

        // Reversed flow (toward center)
        rotUV.y = -rotUV.y;

        float prob;
        float stream = timelineStream(rotUV, seed, -t * 0.3, prob);
        echoes += stream * 0.15 * prob;
    }

    return echoes;
}

// Future timelines
float futureTimelines(vec2 uv, float t, out vec3 timelineColor) {
    float futures = 0.0;
    timelineColor = vec3(0.0);
    float totalWeight = 0.0;

    for(int i = 0; i < 7; i++) {
        float seed = float(i) * 3.33;
        float angle = (float(i) - 3.0) * 0.25;

        vec2 rotUV = vec2(
            uv.x * cos(angle) - uv.y * sin(angle),
            uv.x * sin(angle) + uv.y * cos(angle)
        );

        float prob;
        float stream = timelineStream(rotUV, seed, t, prob);

        // Color based on probability
        vec3 streamColor;
        if(prob > 0.6) {
            streamColor = mix(TIMELINE_BLUE, PROBABILITY_GREEN, (prob - 0.6) * 2.5);
        } else if(prob > 0.3) {
            streamColor = mix(WARNING_AMBER, TIMELINE_BLUE, (prob - 0.3) * 3.3);
        } else {
            streamColor = mix(ORACLE_PURPLE, WARNING_AMBER, prob * 3.3);
        }

        futures += stream * prob;
        timelineColor += streamColor * stream * prob;
        totalWeight += stream * prob;
    }

    if(totalWeight > 0.0) {
        timelineColor /= totalWeight;
    }

    return futures;
}

// Probability fog
float probabilityFog(vec2 uv, float t) {
    float fog = fbm(uv * 3.0 + t * 0.1);
    fog *= fbm(uv * 5.0 - t * 0.15 + 100.0);
    return fog * 0.3;
}

// Scanning forward lines
float scanLines(vec2 uv, float t) {
    float scan = 0.0;

    for(int i = 0; i < 3; i++) {
        float y = mod(t * 0.3 + float(i) * 0.33, 1.0) - 0.5;
        float line = smoothstep(0.02, 0.0, abs(uv.y - y * 0.8));
        line *= smoothstep(0.5, 0.0, abs(uv.x)); // Fade at sides
        scan += line * (1.0 - abs(y) * 2.0);
    }

    return scan * 0.3;
}

// Decision nodes (branch points glowing)
float decisionNodes(vec2 uv, float t) {
    float nodes = 0.0;

    for(int i = 0; i < 6; i++) {
        float seed = float(i) * 5.55;
        vec2 nodePos = vec2(
            (hash(vec2(seed, 0.0)) - 0.5) * 0.5,
            hash(vec2(seed, 1.0)) * 0.3 + 0.1
        );

        float dist = length(uv - nodePos);
        float node = exp(-dist * 30.0);

        // Pulse at decision moment
        float pulse = sin(t * 3.0 + seed) * 0.5 + 0.5;
        pulse = pow(pulse, 4.0);

        nodes += node * (0.3 + pulse * 0.7);
    }

    return nodes;
}

void main() {
    vec2 uv = vUv - 0.5;
    float t = uTime;

    // Background
    vec3 color = TEMPORAL_VOID;

    // Probability fog
    float fog = probabilityFog(uv, t);
    color += ORACLE_PURPLE * fog * 0.3;

    // Past echoes (behind everything)
    float past = pastEchoes(uv, t);
    color += vec3(0.3, 0.3, 0.4) * past; // Desaturated

    // Future timelines
    vec3 timelineColor;
    float futures = futureTimelines(uv, t, timelineColor);
    color += timelineColor * futures * (0.8 + uHover * 0.4);

    // Decision nodes
    float nodes = decisionNodes(uv, t);
    color += WARNING_AMBER * nodes * (0.6 + uHover * 0.4);

    // Present moment (on top)
    float present = presentMoment(uv, t);
    vec3 presentColor = mix(TIMELINE_BLUE, vec3(1.0), present * 0.5);
    color += presentColor * present * (0.8 + uHover * 0.3);

    // Scanning lines
    float scan = scanLines(uv, t);
    color += PROBABILITY_GREEN * scan;

    // Time dilation near center (subtle UV stretch visual)
    float dilation = exp(-length(uv) * 5.0) * 0.1;
    color += ORACLE_PURPLE * dilation;

    // Outer ring of possibilities
    float outerRing = smoothstep(0.01, 0.0, abs(length(uv) - 0.4));
    outerRing *= sin(atan(uv.y, uv.x) * 12.0 + t) * 0.5 + 0.5;
    color += TIMELINE_BLUE * outerRing * 0.2;

    // Vignette
    float vignette = 1.0 - length(uv) * 0.6;
    color *= vignette;

    // Tone mapping
    color = color / (1.0 + color);
    color = pow(color, vec3(0.95));

    gl_FragColor = vec4(color, 1.0);
}
