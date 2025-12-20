/**
 * META-LOGOS: The Cognitive Forge
 * Visual: Digital Renaissance - Liquid Gold forging from Deep Ink chaos.
 * Palette: Ink Black (#0A0A0A), Liquid Gold (#D4AF37), Parchment Mist (#F0EAD6).
 */

precision highp float;

uniform float uTime;
uniform float uHover;
uniform float uClick;
uniform vec2 uMouse;

varying vec2 vUv;

#define PI 3.14159265359

// Digital Renaissance Palette - Refined
const vec3 DEEP_INK = vec3(0.02, 0.02, 0.03); // Slightly bluer black for depth
const vec3 LIQUID_GOLD = vec3(1.0, 0.75, 0.2); // Brighter gold
const vec3 GOLD_SHADOW = vec3(0.4, 0.25, 0.05); // Richer shadow
const vec3 PARCHMENT = vec3(0.96, 0.93, 0.86);

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
    for (int i = 0; i < 6; ++i) { // 6 octaves for high detail
        v += a * noise(p);
        p = p * 2.02; // Slight offset to avoid artifacts
        a *= 0.5;
    }
    return v;
}

// Curl noise for elegant flow
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

void main() {
    vec2 uv = vUv * 2.0 - 1.0;
    float t = uTime * 0.25; // Slower time

    // Domain warping with Curl Noise
    vec3 p = vec3(uv * 2.5, t * 0.15);
    vec3 flow = curlNoise(p);
    
    // Add secondary warp for complexity
    vec3 p2 = p + flow * 0.8;
    float density = fbm(p2);

    // Create sharp "Liquid Metal" thresholds
    float liquid = smoothstep(0.4, 0.45, density);
    float highlights = smoothstep(0.6, 0.8, density);
    float deepShadows = smoothstep(0.2, 0.4, density);
    
    // Specular highlight approximation (metallic shine)
    vec3 lightDir = normalize(vec3(1.0, 1.0, 2.0));
    vec3 normal = normalize(cross(dFdx(vec3(uv, density)), dFdy(vec3(uv, density))));
    float specular = pow(max(dot(normal, lightDir), 0.0), 32.0);

    // Background: Deep Ink with subtle texture
    vec3 color = DEEP_INK;
    color += vec3(0.05) * fbm(p * 10.0); // Subtle paper grain

    // Gold Layer
    vec3 goldColor = mix(GOLD_SHADOW, LIQUID_GOLD, deepShadows);
    goldColor += PARCHMENT * specular * 0.8; // Add shine
    
    // Composite
    color = mix(color, goldColor, liquid);

    // Interaction: Mouse reveals "Pure Idea" (Bright Gold)
    vec2 mouse = uMouse * 2.0 - 1.0;
    float mouseDist = length(uv - mouse);
    float reveal = smoothstep(0.5, 0.0, mouseDist) * uHover;
    color += LIQUID_GOLD * reveal * fbm(p * 20.0) * 0.5;

    // Click: Hammer Strike / Ink Splash
    float dist = length(uv);
    float pulse = smoothstep(0.0, 1.0, uClick) * smoothstep(0.15, 0.0, abs(dist - uClick * 3.0));
    color += PARCHMENT * pulse * 2.5;

    // Vignette
    color *= 1.0 - length(uv * 0.55);
    
    // Contrast & Saturation boost
    color = pow(color, vec3(1.1));

    gl_FragColor = vec4(color, 1.0);
}
