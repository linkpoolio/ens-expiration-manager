import { defineConfig } from 'vite'
import reactRefresh from '@vitejs/plugin-react-refresh'
import path from 'path'
import NodeGlobalsPolyfillPlugin from '@esbuild-plugins/node-globals-polyfill'

// https://vitejs.dev/config/
const prefix = 'UI'
const ensExpirationManagerContractAddress =
  process.env[`${prefix}_ENS_EXPIRATION_MANAGER_CONTRACT_ADDRESS`] || ''

export default defineConfig({
  build: {
    target: 'es2018',
    minify: true,
    outDir: '../build',
    rollupOptions: {
      output: {
        assetFileNames: 'assets/[name][extname]',
        chunkFileNames: 'assets/[name].js',
        entryFileNames: 'assets/[name].js',
        manualChunks(id) {
          if (id.includes('react') || id.includes('react-dom')) {
            return 'vendor'
          }
          if (id.includes('ethers')) {
            return 'ethers'
          }
          if (id.includes('bn.js')) {
            return 'bn'
          }
        }
      }
    }
  },
  define: {
    envENSExpirationManagerContractAddress: JSON.stringify(
      ensExpirationManagerContractAddress
    )
  },
  envPrefix: `${prefix}_`,
  plugins: [reactRefresh()],
  root: './src',
  server: {
    port: 3005
  },
  resolve: {
    alias: {
      '@ui': path.resolve(__dirname, './src')
    }
  },
  optimizeDeps: {
    esbuildOptions: {
      define: {
        global: 'globalThis'
      },
      plugins: [
        NodeGlobalsPolyfillPlugin({
          buffer: true
        })
      ]
    }
  }
})
