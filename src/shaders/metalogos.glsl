/**
 * META-LOGOS: The Cognitive Forge
 * Visual: Digital Renaissance - Liquid Gold forging from Deep Ink chaos.
 * 
 * FIX v2: Proper value noise instead of gradient noise for stable output
 */

precision highp float;

uniform float uTime;
uniform float uHover;
uniform float uClick;
uniform vec2 uMouse;

varying vec2 vUv;

#define PI 3.14159265359

// Digital Renaissance Palette
const vec3 DEEP_INK = vec3(0.03, 0.03, 0.05);
const vec3 LIQUID_GOLD = vec3(1.0, 0.78, 0.25);
const vec3 GOLD_SHADOW = vec3(0.5, 0.32, 0.08);
const vec3 PARCHMENT = vec3(0.96, 0.93, 0.86);

// Simple hash for value noise
float hash(vec3 p) {
    p = fract(p * vec3(443.897, 441.423, 437.195));
    p += dot(p, p.yzx + 19.19);
    return fract((p.x + p.y) * p.z);
}

// Value noise (returns 0-1)
float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    return mix(
        mix(mix(hash(i + vec3(0,0,0)), hash(i + vec3(1,0,0)), f.x),
            mix(hash(i + vec3(0,1,0)), hash(i + vec3(1,1,0)), f.x), f.y),
        mix(mix(hash(i + vec3(0,0,1)), hash(i + vec3(1,0,1)), f.x),
            mix(hash(i + vec3(0,1,1)), hash(i + vec3(1,1,1)), f.x), f.y),
        f.z
    );
}

float fbm(vec3 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 5; ++i) {
        v += a * noise(p);
        p = p * 2.03;
        a *= 0.5;
    }
    return v;
}

void main() {
    vec2 uv = vUv * 2.0 - 1.0;
    float t = uTime * 0.3;

    // Domain warping
    vec3 p = vec3(uv * 2.0, t * 0.2);
    float warp = fbm(p * 2.0);
    vec3 p2 = p + vec3(warp * 0.5);
    
    float density = fbm(p2);

    // Create liquid metal effect
    float liquid = smoothstep(0.35, 0.5, density);
    float highlights = smoothstep(0.55, 0.7, density);
    
    // Specular approximation
    vec3 lightDir = normalize(vec3(1.0, 1.0, 2.0));
    float dx = fbm(p2 + vec3(0.01, 0, 0)) - fbm(p2 - vec3(0.01, 0, 0));
    float dy = fbm(p2 + vec3(0, 0.01, 0)) - fbm(p2 - vec3(0, 0.01, 0));
    vec3 normal = normalize(vec3(-dx * 5.0, -dy * 5.0, 1.0));
    float specular = pow(max(dot(normal, lightDir), 0.0), 16.0);

    // Background with subtle texture
    vec3 color = DEEP_INK;
    color += vec3(0.03) * fbm(p * 8.0);

    // Gold Layer
    vec3 goldColor = mix(GOLD_SHADOW, LIQUID_GOLD, density);
    goldColor += PARCHMENT * specular * 0.6;
    
    // Composite
    color = mix(color, goldColor, liquid);
    color += LIQUID_GOLD * highlights * 0.3;

    // Mouse interaction
    vec2 mouse = uMouse * 2.0 - 1.0;
    float mouseDist = length(uv - mouse);
    float reveal = smoothstep(0.5, 0.0, mouseDist) * uHover;
    color += LIQUID_GOLD * reveal * 0.3;

    // Click pulse
    float dist = length(uv);
    float pulse = uClick * smoothstep(0.2, 0.0, abs(dist - uClick * 2.0));
    color += PARCHMENT * pulse * 2.0;

    // Soft vignette
    color *= 1.0 - length(uv * 0.4);
    
    // Gamma
    color = pow(color, vec3(0.9));

    gl_FragColor = vec4(color, 1.0);
}
