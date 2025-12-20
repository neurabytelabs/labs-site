/**
 * LITHOSPHERE - N-Body Gravitational Dance
 * Three cosmic bodies locked in eternal gravitational waltz
 * Space-time bending like silk around their mass
 *
 * Visual: Generative data art meets astrophysics
 * Palette: Solar Plasma Orange, Nebula Teal, Starlight White
 */

precision highp float;

uniform float uTime;
uniform float uHover;
uniform vec2 uMouse;

varying vec2 vUv;

#define PI 3.14159265359
#define TAU 6.28318530718

// Color palette
const vec3 SOLAR_PLASMA = vec3(1.0, 0.42, 0.21);
const vec3 NEBULA_TEAL = vec3(0.31, 0.80, 0.77);
const vec3 STARLIGHT = vec3(0.97, 1.0, 0.97);
const vec3 DEEP_SPACE = vec3(0.10, 0.10, 0.18);

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

// Three-body orbital positions (chaotic but bounded)
vec2 body1Pos(float t) {
    float a = t * 0.3;
    float b = t * 0.47;
    return vec2(
        sin(a) * 0.22 + sin(b * 1.3) * 0.08,
        cos(a * 0.8) * 0.18 + cos(b) * 0.1
    );
}

vec2 body2Pos(float t) {
    float a = t * 0.4 + 2.094;
    float b = t * 0.31;
    return vec2(
        sin(a * 0.9) * 0.24 + sin(b * 1.1) * 0.06,
        cos(a) * 0.19 + cos(b * 0.7) * 0.08
    );
}

vec2 body3Pos(float t) {
    float a = t * 0.35 + 4.189;
    float b = t * 0.53;
    return vec2(
        sin(a * 1.1) * 0.20 + sin(b * 0.9) * 0.09,
        cos(a * 0.85) * 0.21 + cos(b * 1.2) * 0.07
    );
}

// Gravitational lensing distortion
vec2 gravitationalLens(vec2 uv, vec2 massPos, float mass) {
    vec2 delta = uv - massPos;
    float dist = length(delta);
    float strength = mass / (dist * dist + 0.08);
    return uv + normalize(delta + 0.001) * strength * 0.012;
}

// Star field with parallax
float stars(vec2 uv, float layer) {
    vec2 grid = floor(uv * (15.0 + layer * 8.0));
    vec2 local = fract(uv * (15.0 + layer * 8.0));

    float h = hash(grid + layer * 100.0);
    vec2 starPos = vec2(h, hash(grid.yx + layer * 100.0)) * 0.8 + 0.1;

    float dist = length(local - starPos);
    float brightness = h * h * h;
    float size = 0.03 + h * 0.03;

    return smoothstep(size, 0.0, dist) * brightness;
}

// Nebula clouds
vec3 nebula(vec2 uv, float t) {
    float n1 = fbm(uv * 2.5 + t * 0.05);
    float n2 = fbm(uv * 3.5 - t * 0.03 + 100.0);
    float n3 = fbm(uv * 2.0 + t * 0.02 + 200.0);

    vec3 col = vec3(0.0);
    col += NEBULA_TEAL * n1 * 0.12;
    col += SOLAR_PLASMA * n2 * 0.08;
    col += vec3(0.4, 0.2, 0.6) * n3 * 0.06;

    return col;
}

// Glowing sphere with corona
float sphere(vec2 uv, vec2 pos, float radius, float hover) {
    float dist = length(uv - pos);

    // Core
    float core = smoothstep(radius, radius * 0.2, dist);

    // Corona glow - enhanced on hover
    float coronaStrength = 40.0 - hover * 15.0;
    float corona = 1.0 / (1.0 + dist * dist * coronaStrength) * radius * 2.5;

    // Outer halo
    float halo = exp(-dist * (6.0 - hover * 2.0)) * 0.6;

    return core + corona + halo;
}

// Gravitational flow lines
float flowLines(vec2 uv, vec2 b1, vec2 b2, vec2 b3, float t) {
    // Calculate gravitational field direction
    vec2 field = vec2(0.0);
    field += normalize(b1 - uv + 0.001) / (length(b1 - uv) + 0.15);
    field += normalize(b2 - uv + 0.001) / (length(b2 - uv) + 0.15);
    field += normalize(b3 - uv + 0.001) / (length(b3 - uv) + 0.15);

    // Flow visualization
    float angle = atan(field.y, field.x);
    float flowPattern = sin(angle * 6.0 + length(field) * 8.0 - t * 2.0);
    float flow = smoothstep(0.7, 1.0, flowPattern) * 0.25;

    return flow * (1.0 - smoothstep(0.0, 0.6, length(field)));
}

// Particle trails
float particleTrail(vec2 uv, vec2 pos, vec2 vel) {
    float trail = 0.0;
    for(int i = 0; i < 10; i++) {
        float age = float(i) * 0.08;
        vec2 trailPos = pos - vel * age;
        float dist = length(uv - trailPos);
        trail += exp(-dist * 35.0) * (1.0 - age / 0.8);
    }
    return trail * 0.25;
}

void main() {
    vec2 uv = vUv - 0.5;
    float t = uTime * 0.5;

    // Get body positions
    vec2 b1 = body1Pos(t);
    vec2 b2 = body2Pos(t);
    vec2 b3 = body3Pos(t);

    // Apply gravitational lensing to UV - enhanced on hover
    float lensStrength = 1.0 + uHover * 0.5;
    vec2 lensedUV = uv;
    lensedUV = gravitationalLens(lensedUV, b1, 0.7 * lensStrength);
    lensedUV = gravitationalLens(lensedUV, b2, 0.5 * lensStrength);
    lensedUV = gravitationalLens(lensedUV, b3, 0.4 * lensStrength);

    // Background: Deep space
    vec3 color = DEEP_SPACE;

    // Add nebula clouds
    color += nebula(lensedUV, t);

    // Star layers with parallax
    float starField = 0.0;
    starField += stars(lensedUV * 1.0 + t * 0.008, 0.0);
    starField += stars(lensedUV * 1.3 + t * 0.015, 1.0) * 0.6;
    starField += stars(lensedUV * 1.8 + t * 0.02, 2.0) * 0.4;
    color += STARLIGHT * starField;

    // Gravitational flow lines
    color += vec3(0.25, 0.45, 0.7) * flowLines(uv, b1, b2, b3, t);

    // Velocity for trails
    vec2 v1 = body1Pos(t + 0.01) - b1;
    vec2 v2 = body2Pos(t + 0.01) - b2;
    vec2 v3 = body3Pos(t + 0.01) - b3;

    // Particle trails (behind bodies)
    color += SOLAR_PLASMA * particleTrail(uv, b1, v1 * 80.0) * 0.4;
    color += NEBULA_TEAL * particleTrail(uv, b2, v2 * 80.0) * 0.35;
    color += mix(SOLAR_PLASMA, NEBULA_TEAL, 0.5) * particleTrail(uv, b3, v3 * 80.0) * 0.3;

    // Body 1: Solar (largest, warmest)
    float body1 = sphere(uv, b1, 0.07, uHover);
    vec3 body1Color = mix(SOLAR_PLASMA, STARLIGHT, body1 * 0.4);
    color += body1Color * body1;

    // Body 2: Teal planet
    float body2 = sphere(uv, b2, 0.055, uHover);
    vec3 body2Color = mix(NEBULA_TEAL, STARLIGHT, body2 * 0.3);
    color += body2Color * body2;

    // Body 3: Mixed
    float body3 = sphere(uv, b3, 0.045, uHover);
    vec3 body3Color = mix(mix(SOLAR_PLASMA, NEBULA_TEAL, 0.5), STARLIGHT, body3 * 0.35);
    color += body3Color * body3;

    // Chromatic aberration near masses
    float distToMass = min(min(length(uv - b1), length(uv - b2)), length(uv - b3));
    float aberration = smoothstep(0.25, 0.0, distToMass) * 0.025 * (1.0 + uHover * 0.5);
    color.r += aberration;
    color.b -= aberration;

    // Vignette
    float vignette = 1.0 - length(uv) * 0.6;
    color *= vignette;

    // Tone mapping
    color = color / (1.0 + color);
    color = pow(color, vec3(0.95));

    gl_FragColor = vec4(color, 1.0);
}
