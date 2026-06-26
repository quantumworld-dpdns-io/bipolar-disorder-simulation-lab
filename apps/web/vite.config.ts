// apps/web/vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { TanStackRouter } from '@tanstack/router-vite-plugin'

export default defineConfig({
  plugins: [
    react(),
    TanStackRouter(),
  ],
  build: {
    outDir: '../dist',
    rollupOptions: {
      output: {
        assetFileNames: 'assets/[name]-[hash].[ext]',
      },
    },
  },
})