/**
 * DIGITAL RENAISSANCE - Sacred Geometry
 * Ancient sacred geometry awakening with digital fire
 * Flower of Life, Metatron's Cube, Golden Spiral interlocking
 *
 * Visual: Da Vinci's Vitruvian Man meets digital transcendence
 * Palette: Illuminated Gold, Parchment Umber, Renaissance Blue
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
const vec3 ILLUMINATED_GOLD = vec3(0.83, 0.69, 0.22);
const vec3 PARCHMENT_UMBER = vec3(0.55, 0.27, 0.07);
const vec3 VELLUM_CREAM = vec3(0.91, 0.84, 0.72);
const vec3 RENAISSANCE_BLUE = vec3(0.12, 0.23, 0.37);
const vec3 INK_BLACK = vec3(0.05, 0.05, 0.05);

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

// Parchment texture
float parchmentTexture(vec2 uv) {
    float n1 = noise(uv * 50.0);
    float n2 = noise(uv * 100.0) * 0.5;
    float n3 = noise(uv * 200.0) * 0.25;
    return n1 + n2 + n3;
}

// Circle for Flower of Life
float circle(vec2 uv, vec2 center, float radius) {
    float dist = length(uv - center);
    return smoothstep(0.008, 0.0, abs(dist - radius));
}

// Flower of Life pattern
float flowerOfLife(vec2 uv, float t) {
    float pattern = 0.0;
    float radius = 0.1;

    // Center circle
    pattern += circle(uv, vec2(0.0), radius);

    // First ring: 6 circles
    for(int i = 0; i < 6; i++) {
        float angle = float(i) * TAU / 6.0 + t * 0.05;
        vec2 center = vec2(cos(angle), sin(angle)) * radius;
        pattern += circle(uv, center, radius);
    }

    // Second ring: 6 more circles (petals)
    for(int i = 0; i < 6; i++) {
        float angle = float(i) * TAU / 6.0 + TAU / 12.0 + t * 0.05;
        vec2 center = vec2(cos(angle), sin(angle)) * radius * 1.732;
        pattern += circle(uv, center, radius);
    }

    // Third ring: outer circles
    for(int i = 0; i < 12; i++) {
        float angle = float(i) * TAU / 12.0 + t * 0.03;
        vec2 center = vec2(cos(angle), sin(angle)) * radius * 2.0;
        pattern += circle(uv, center, radius) * 0.5;
    }

    return min(pattern, 1.0);
}

// Metatron's Cube (13 circles with connecting lines)
float metatronsCube(vec2 uv, float t) {
    float pattern = 0.0;
    float radius = 0.03;

    // 13 points of Metatron's Cube
    vec2 points[13];
    points[0] = vec2(0.0, 0.0); // Center

    // Inner hexagon
    for(int i = 0; i < 6; i++) {
        float angle = float(i) * TAU / 6.0 + PI / 6.0;
        points[i + 1] = vec2(cos(angle), sin(angle)) * 0.12;
    }

    // Outer hexagon
    for(int i = 0; i < 6; i++) {
        float angle = float(i) * TAU / 6.0;
        points[i + 7] = vec2(cos(angle), sin(angle)) * 0.21;
    }

    // Draw points
    for(int i = 0; i < 13; i++) {
        float dist = length(uv - points[i]);
        pattern += exp(-dist * 50.0) * 0.5;
        pattern += smoothstep(radius + 0.005, radius, dist) * 0.3;
    }

    // Draw connecting lines
    for(int i = 0; i < 13; i++) {
        for(int j = i + 1; j < 13; j++) {
            vec2 a = points[i];
            vec2 b = points[j];

            // Line segment distance
            vec2 pa = uv - a;
            vec2 ba = b - a;
            float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
            float d = length(pa - ba * h);

            float line = smoothstep(0.004, 0.0, d);
            float pulse = sin(t * 2.0 + float(i + j) * 0.3) * 0.3 + 0.7;
            pattern += line * 0.08 * pulse;
        }
    }

    return pattern;
}

// Golden Spiral
float goldenSpiral(vec2 uv, float t) {
    float spiral = 0.0;

    float r = length(uv);
    float theta = atan(uv.y, uv.x);

    // Multiple spiral arms
    for(int i = 0; i < 4; i++) {
        float offset = float(i) * TAU / 4.0 + t * 0.1;

        // Logarithmic spiral: r = a * e^(b * theta)
        float b = 0.3063; // Related to golden ratio
        float spiralR = 0.02 * exp(b * (theta + offset + t * 0.2));

        // Wrap around
        for(int w = -2; w <= 2; w++) {
            float wrapR = 0.02 * exp(b * (theta + offset + float(w) * TAU));
            float dist = abs(r - wrapR);
            spiral += smoothstep(0.008, 0.0, dist) * 0.3;
        }
    }

    return spiral;
}

// Phi grid
float phiGrid(vec2 uv, float t) {
    float grid = 0.0;

    // Phi-based divisions
    float divisions[5];
    divisions[0] = 0.0;
    divisions[1] = 1.0 / (PHI * PHI);
    divisions[2] = 1.0 / PHI;
    divisions[3] = 1.0 - 1.0 / PHI;
    divisions[4] = 1.0 - 1.0 / (PHI * PHI);

    for(int i = 0; i < 5; i++) {
        float pos = divisions[i] - 0.5;
        float hLine = smoothstep(0.003, 0.0, abs(uv.y - pos * 0.8));
        float vLine = smoothstep(0.003, 0.0, abs(uv.x - pos * 0.8));

        float pulse = sin(t + float(i)) * 0.3 + 0.7;
        grid += (hLine + vLine) * 0.15 * pulse;
    }

    return grid;
}

// Mathematical symbols floating
float mathSymbols(vec2 uv, float t) {
    float symbols = 0.0;

    for(int i = 0; i < 8; i++) {
        float seed = float(i) * 5.55;

        // Floating position
        vec2 pos = vec2(
            sin(t * 0.3 + seed) * 0.3 + (hash(vec2(seed, 0.0)) - 0.5) * 0.4,
            cos(t * 0.25 + seed * 0.7) * 0.25 + (hash(vec2(0.0, seed)) - 0.5) * 0.3
        );

        float dist = length(uv - pos);
        float symbol = exp(-dist * 40.0);

        float pulse = sin(t * 2.0 + seed) * 0.4 + 0.6;
        symbols += symbol * 0.4 * pulse;
    }

    return symbols;
}

// Light rays from center
float lightRays(vec2 uv, float t) {
    float rays = 0.0;

    float angle = atan(uv.y, uv.x);
    float dist = length(uv);

    // Multiple ray frequencies
    rays += sin(angle * 12.0 + t * 0.5) * 0.5 + 0.5;
    rays *= smoothstep(0.4, 0.1, dist);
    rays *= smoothstep(0.0, 0.05, dist);

    return rays * 0.15;
}

// Ornate border
float ornateBorder(vec2 uv, float t) {
    float border = 0.0;

    float maxCoord = max(abs(uv.x), abs(uv.y));

    // Outer frame
    border += smoothstep(0.005, 0.0, abs(maxCoord - 0.42));
    border += smoothstep(0.003, 0.0, abs(maxCoord - 0.40)) * 0.5;
    border += smoothstep(0.003, 0.0, abs(maxCoord - 0.38)) * 0.3;

    // Corner flourishes
    for(int i = 0; i < 4; i++) {
        float angle = float(i) * TAU / 4.0 + TAU / 8.0;
        vec2 corner = vec2(cos(angle), sin(angle)) * 0.42;

        float cornerDist = length(uv - corner);
        float flourish = exp(-cornerDist * 15.0);
        float pulse = sin(t * 1.5 + float(i) * TAU / 4.0) * 0.3 + 0.7;

        border += flourish * 0.5 * pulse;
    }

    return border;
}

void main() {
    vec2 uv = vUv - 0.5;
    float t = uTime;

    // Parchment background
    float parchment = parchmentTexture(vUv);
    vec3 color = mix(INK_BLACK, PARCHMENT_UMBER, 0.15 + parchment * 0.1);

    // Add vellum tone
    color += VELLUM_CREAM * 0.05;

    // Phi grid (subtle background)
    float phi = phiGrid(uv, t);
    color += RENAISSANCE_BLUE * phi * 0.5;

    // Light rays
    float rays = lightRays(uv, t);
    color += ILLUMINATED_GOLD * rays;

    // Golden Spiral
    float spiral = goldenSpiral(uv, t);
    color += ILLUMINATED_GOLD * spiral * (0.6 + uHover * 0.4);

    // Flower of Life
    float flower = flowerOfLife(uv, t);
    color += ILLUMINATED_GOLD * flower * 0.4;

    // Metatron's Cube (overlay)
    float metatron = metatronsCube(uv, t);
    color += mix(ILLUMINATED_GOLD, VELLUM_CREAM, 0.3) * metatron * (0.5 + uHover * 0.3);

    // Mathematical symbols
    float symbols = mathSymbols(uv, t);
    color += ILLUMINATED_GOLD * symbols;

    // Ornate border
    float border = ornateBorder(uv, t);
    color += ILLUMINATED_GOLD * border * 0.6;

    // Central enlightenment glow
    float centerGlow = exp(-length(uv) * 8.0) * 0.3;
    color += VELLUM_CREAM * centerGlow;

    // Vignette (darker edges like aged manuscript)
    float vignette = 1.0 - length(uv) * 0.7;
    vignette = smoothstep(0.0, 1.0, vignette);
    color *= vignette;

    // Aged paper darkening at edges
    float age = smoothstep(0.3, 0.5, length(uv));
    color = mix(color, color * 0.7, age * 0.3);

    // Tone mapping
    color = color / (1.0 + color);
    color = pow(color, vec3(0.95));

    // Slight sepia tone
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 sepia = vec3(luminance * 1.1, luminance * 0.95, luminance * 0.8);
    color = mix(color, sepia, 0.15);

    gl_FragColor = vec4(color, 1.0);
}
