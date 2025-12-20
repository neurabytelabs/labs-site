/**
 * NEURABYTE VOICE - Acoustic Sculpture
 * The human voice made visible as luminous sculpture
 * Sound waves frozen in 3D space, harmonics as nested geometric shells
 *
 * Visual: Cymatics meets bioluminescence
 * Palette: Voice Cyan, Harmonic Violet, Resonance Rose, Frequency Green
 */

precision highp float;

uniform float uTime;
uniform float uHover;
uniform vec2 uMouse;

varying vec2 vUv;

#define PI 3.14159265359
#define TAU 6.28318530718

// Color palette
const vec3 VOICE_CYAN = vec3(0.13, 0.83, 0.93);
const vec3 HARMONIC_VIOLET = vec3(0.66, 0.55, 0.98);
const vec3 RESONANCE_ROSE = vec3(0.98, 0.44, 0.52);
const vec3 FREQUENCY_GREEN = vec3(0.20, 0.83, 0.60);
const vec3 SILENT_BLACK = vec3(0.04, 0.04, 0.05);

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

// Simulated audio input (since we don't have real audio)
float simulatedAudio(float freq, float t) {
    float base = sin(t * freq * TAU) * 0.5;
    float harm1 = sin(t * freq * 2.0 * TAU) * 0.25;
    float harm2 = sin(t * freq * 3.0 * TAU) * 0.125;
    float noise = hash(vec2(t * 10.0, freq)) * 0.1;
    return (base + harm1 + harm2 + noise) * 0.5 + 0.5;
}

// Main voice waveform (toroidal cross-section)
float voiceWaveform(vec2 uv, float t) {
    float waveform = 0.0;

    // Complex waveform from multiple frequencies
    float wave = 0.0;
    for(int i = 1; i <= 8; i++) {
        float freq = float(i);
        float amplitude = 1.0 / freq;
        float phase = t * (1.0 + float(i) * 0.3);
        wave += sin(uv.x * freq * 15.0 + phase * 3.0) * amplitude;
    }
    wave *= 0.08;

    // Envelope modulation (speech-like)
    float envelope = sin(t * 0.8) * 0.5 + 0.5;
    envelope *= sin(t * 2.3) * 0.3 + 0.7;
    wave *= envelope;

    // Distance to wave
    float dist = abs(uv.y - wave);
    waveform = smoothstep(0.02, 0.005, dist);

    // Glow
    float glow = exp(-dist * 30.0) * envelope * 0.5;

    return waveform + glow;
}

// Harmonic frequency shells (concentric rings at harmonic intervals)
float harmonicShells(vec2 uv, float t) {
    float shells = 0.0;
    float r = length(uv);

    // Fundamental + harmonics (1x, 2x, 3x, 4x, 5x)
    for(int i = 1; i <= 5; i++) {
        float harmonic = float(i);
        float amplitude = 1.0 / harmonic; // Natural harmonic decay
        float baseRadius = 0.1 + float(i) * 0.06;

        // Radius oscillates with frequency
        float freq = harmonic * 0.5;
        float oscillation = sin(t * freq * TAU) * 0.015 * amplitude;
        float radius = baseRadius + oscillation;

        // Shell ring
        float shell = smoothstep(0.015, 0.0, abs(r - radius));

        // Modulate thickness with "volume"
        float volume = simulatedAudio(harmonic * 0.3, t);
        shell *= 0.3 + volume * 0.7;

        shells += shell * amplitude;
    }

    return shells;
}

// Cymatic-inspired 2D wave interference pattern
float cymaticPattern(vec2 uv, float t) {
    float pattern = 0.0;

    // Multiple wave sources creating interference
    for(int i = 0; i < 4; i++) {
        float angle = float(i) * TAU / 4.0 + t * 0.2;
        float freq = 2.0 + float(i) * 0.5;

        vec2 source = vec2(cos(angle), sin(angle)) * 0.3;
        float dist = length(uv - source);

        float wave = sin(dist * freq * 30.0 - t * 4.0);
        pattern += wave;
    }

    // Normalize and threshold
    pattern = pattern / 4.0;
    pattern = smoothstep(-0.5, 0.5, pattern);

    // Only show in certain region
    float mask = smoothstep(0.45, 0.35, length(uv));
    mask *= smoothstep(0.1, 0.2, length(uv));

    return pattern * mask * 0.15;
}

// Sound propagation ripples
float soundRipples(vec2 uv, float t) {
    float ripples = 0.0;

    for(int i = 0; i < 5; i++) {
        float birthTime = float(i) * 0.6;
        float age = mod(t + birthTime, 3.0);
        float radius = age * 0.15;

        float dist = length(uv);
        float ripple = smoothstep(0.02, 0.0, abs(dist - radius));
        ripple *= (1.0 - age / 3.0); // Fade with distance

        ripples += ripple * 0.3;
    }

    return ripples;
}

// Frequency spectrum visualization (bottom bar)
float spectrumBars(vec2 uv, float t) {
    float spectrum = 0.0;

    // 16 frequency bands
    for(int i = 0; i < 16; i++) {
        float barX = (float(i) - 7.5) / 8.0 * 0.35;
        float freq = float(i + 1) * 0.2;

        // Simulated frequency magnitude
        float mag = simulatedAudio(freq, t);
        mag = pow(mag, 1.5); // More dynamic range

        float barHeight = mag * 0.12;

        // Bar shape
        float inBar = step(abs(uv.x - barX), 0.008);
        inBar *= step(uv.y, -0.32 + barHeight);
        inBar *= step(-0.35, uv.y);

        spectrum += inBar;
    }

    return spectrum;
}

// Voice sculpture - 3D-like central form
float voiceSculpture(vec2 uv, float t) {
    float sculpture = 0.0;

    float r = length(uv);
    float angle = atan(uv.y, uv.x);

    // Morphing phoneme shape
    float morph = sin(t * 0.5) * 0.5 + 0.5;
    float shape1 = 0.08 + sin(angle * 3.0 + t) * 0.02; // Triangle-ish
    float shape2 = 0.08 + sin(angle * 2.0 + t * 1.3) * 0.025; // Oval-ish
    float targetR = mix(shape1, shape2, morph);

    // Core shape
    float core = smoothstep(targetR + 0.01, targetR - 0.01, r);

    // Inner structure
    float innerRings = 0.0;
    for(int i = 1; i <= 3; i++) {
        float ringR = targetR * (1.0 - float(i) * 0.25);
        float ring = smoothstep(0.005, 0.0, abs(r - ringR));
        innerRings += ring * 0.3;
    }

    // Outer glow
    float glow = exp(-r * 15.0) * 0.4;

    // Vibration displacement
    float vibration = sin(angle * 8.0 + t * 10.0) * 0.003;
    float vibrantDist = abs(r - targetR - vibration);
    float vibrantEdge = smoothstep(0.01, 0.0, vibrantDist);

    sculpture = core * 0.3 + innerRings + glow + vibrantEdge * 0.5;

    return sculpture;
}

// Floating phoneme particles
float phonemeParticles(vec2 uv, float t) {
    float particles = 0.0;

    for(int i = 0; i < 20; i++) {
        float seed = float(i) * 7.77;

        // Radiate outward from center
        float birthTime = hash(vec2(seed, 0.0)) * 4.0;
        float age = mod(t + birthTime, 4.0);

        float angle = hash(vec2(0.0, seed)) * TAU;
        float speed = 0.08 + hash(vec2(seed, seed)) * 0.04;
        float radius = age * speed;

        vec2 pos = vec2(cos(angle), sin(angle)) * radius;

        float dist = length(uv - pos);
        float particle = exp(-dist * 50.0) * (1.0 - age / 4.0);

        particles += particle * 0.3;
    }

    return particles;
}

void main() {
    vec2 uv = vUv - 0.5;
    float t = uTime;

    // Simulated "volume" for reactivity
    float volume = simulatedAudio(1.0, t);

    // Background - silent black with subtle gradient
    vec3 color = SILENT_BLACK;
    color += vec3(0.02, 0.03, 0.05) * (1.0 - length(uv));

    // Cymatic interference pattern (background)
    float cymatics = cymaticPattern(uv, t);
    color += HARMONIC_VIOLET * cymatics;

    // Sound ripples
    float ripples = soundRipples(uv, t);
    color += VOICE_CYAN * ripples * (0.5 + volume * 0.5);

    // Harmonic shells
    float shells = harmonicShells(uv, t);
    color += mix(VOICE_CYAN, HARMONIC_VIOLET, length(uv) * 2.0) * shells * (0.6 + uHover * 0.4);

    // Voice sculpture (central)
    float sculpture = voiceSculpture(uv, t);
    vec3 sculptureColor = mix(VOICE_CYAN, RESONANCE_ROSE, volume);
    color += sculptureColor * sculpture * (0.7 + uHover * 0.3);

    // Main waveform (through center)
    float waveform = voiceWaveform(uv, t);
    color += VOICE_CYAN * waveform * (0.5 + volume * 0.5);

    // Phoneme particles
    float particles = phonemeParticles(uv, t);
    color += mix(FREQUENCY_GREEN, RESONANCE_ROSE, hash(vec2(t, 0.0))) * particles;

    // Spectrum bars (bottom)
    float spectrum = spectrumBars(uv, t);
    vec3 spectrumColor = mix(FREQUENCY_GREEN, VOICE_CYAN, (uv.x + 0.5));
    color += spectrumColor * spectrum * (0.5 + uHover * 0.5);

    // Reactive flash on "loud" moments
    float loudness = pow(volume, 3.0);
    color += vec3(1.0, 0.95, 0.9) * loudness * 0.1;

    // Vignette
    float vignette = 1.0 - length(uv) * 0.5;
    color *= vignette;

    // Tone mapping
    color = color / (1.0 + color);
    color = pow(color, vec3(0.95));

    gl_FragColor = vec4(color, 1.0);
}
