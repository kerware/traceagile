/// <reference types="vitest/config" />
import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';

// En développement, l'API tourne sur le port 8085 (voir CLAUDE.md) ; en conteneur, nginx fait le relais.
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': 'http://localhost:8085',
    },
  },
  build: {
    // L'éditeur Markdown (coloration de code incluse) pèse ~1 Mo mais n'est chargé que sur la fiche exigence.
    chunkSizeWarningLimit: 1200,
    rollupOptions: {
      output: {
        manualChunks: {
          react: ['react', 'react-dom', 'react-router-dom'],
          mantine: ['@mantine/core', '@mantine/hooks', '@mantine/notifications'],
          data: ['@tanstack/react-query', 'openapi-fetch', 'zustand', 'i18next', 'react-i18next'],
          'markdown-editor': ['@uiw/react-md-editor', 'rehype-sanitize'],
        },
      },
    },
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/polyfills.ts', './src/test/setup.ts'],
    css: false,
    // Les écrans riches (fiche exigence, éditeur Markdown) dépassent 5 s sur un poste chargé.
    testTimeout: 15_000,
  },
});
