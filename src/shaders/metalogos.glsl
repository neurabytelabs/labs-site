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

// Digital Renaissance Palette
const vec3 DEEP_INK = vec3(0.04, 0.04, 0.04);
const vec3 LIQUID_GOLD = vec3(0.83, 0.68, 0.21);
const vec3 PARCHMENT = vec3(0.94, 0.91, 0.83);
const vec3 BURNT_SIENNA = vec3(0.54, 0.27, 0.07);

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
    for (int i = 0; i < 5; ++i) { // Increased octaves for detail
        v += a * noise(p);
        p = p * 2.0;
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
    float t = uTime * 0.4; // Slower, majestic flow

    // Background: Deep Ink
    vec3 color = DEEP_INK;

    // Fluid Flow Field
    vec3 p = vec3(uv * 3.0, t * 0.2);
    vec3 flow = curlNoise(p);
    
    // Gold Veins / Structure from Chaos
    float veins = fbm(p + flow * 1.5);
    veins = smoothstep(0.3, 0.7, veins);
    
    // Molten Gold accumulation
    float molten = fbm(p * 2.0 - flow * 0.5);
    molten = smoothstep(0.4, 0.8, molten);

    // Coloring
    // 1. Dark burnt undertones
    color = mix(color, BURNT_SIENNA, veins * 0.5);
    
    // 2. Liquid Gold main body
    color = mix(color, LIQUID_GOLD, molten * veins);
    
    // 3. Parchment highlights (Steam/Heat)
    float steam = fbm(p * 4.0 + vec3(0, t, 0));
    color += PARCHMENT * steam * 0.1 * molten;

    // Interaction: Mouse reveals structure (Gold leaf effect)
    vec2 mouse = uMouse * 2.0 - 1.0;
    float mouseDist = length(uv - mouse);
    float reveal = smoothstep(0.6, 0.0, mouseDist) * uHover;
    
    color += LIQUID_GOLD * reveal * 0.5 * fbm(p * 10.0); // Gold dust

    // Click: Forging Hammer Strike
    // A expanding ring of pure energy (Parchment/White)
    float dist = length(uv);
    float pulse = smoothstep(0.0, 1.0, uClick) * smoothstep(0.2, 0.0, abs(dist - uClick * 2.5));
    color += PARCHMENT * pulse * 2.0;
    
    // Vignette
    color *= 1.0 - length(uv * 0.6);

    // Final tone mapping
    color = pow(color, vec3(1.1)); // Contrast

    gl_FragColor = vec4(color, 1.0);
}
