import { defineConfig } from 'vite';
import glsl from 'vite-plugin-glsl';

export default defineConfig({
  plugins: [
    glsl({
      include: ['**/shaders/**/*.glsl', '**/*.vert', '**/*.frag'],
      exclude: ['node_modules/**', '**/*.js', '**/*.ts'],
      compress: false
    })
  ],
  build: {
    outDir: 'dist',
    minify: 'esbuild',
    sourcemap: false
  },
  server: {
    port: 3000,
    open: true
  }
});
