import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react-swc'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      // Proxy para la API de Ventas (Puerto 8080)
      '/api/v1/ventas': {
        target: 'http://backend-ventas-service:8080',
        changeOrigin: true,
      },
      // Proxy para la API de Despachos (Puerto 8081)
      '/api/v1/despachos': {
        target: 'http://backend-despachos-service:8081',
        changeOrigin: true,
      }
    }
  }
})