import { sentryVitePlugin } from '@sentry/vite-plugin'
import react from '@vitejs/plugin-react'
import dotenv from 'dotenv';
import path from 'path'
import { visualizer } from 'rollup-plugin-visualizer'
import { defineConfig, splitVendorChunkPlugin } from 'vite'
import svgr from 'vite-plugin-svgr'

dotenv.config();


export default defineConfig({
    plugins: [
        react(),
        svgr({ include: '**/*.svg?react' }),
        splitVendorChunkPlugin(),
        visualizer({
            open: true,
            gzipSize: true,
            brotliSize: true,
        }),
        sentryVitePlugin({
            authToken: process.env.VITE_SENTRY_AUTH_TOKEN,
            org: 'cephadex',
            project: 'cephadex',
            release: {name: 'beta', version: '0.1.0'},
        }),
    ],

    server: {
        host: '0.0.0.0',
        proxy: {
            '/*': {
                target: 'http://localhost:5000',
                changeOrigin: true,
            },
        },
        watch: {
            usePolling: true,
        },
    },

    resolve: {
        alias: {
            '@source': path.resolve(__dirname, 'src'),
            '@assets': path.resolve(__dirname, 'src/assets'),
            '@pages': path.resolve(__dirname, 'src/pages'),
            '@account': path.resolve(__dirname, 'src/pages/Account'),
            '@blog': path.resolve(__dirname, 'src/pages/Blog'),
            '@contact': path.resolve(__dirname, 'src/pages/Contact'),
            '@dashboard': path.resolve(__dirname, 'src/pages/Dashboard'),
            '@deck': path.resolve(__dirname, 'src/pages/Deck'),
            '@decks': path.resolve(__dirname, 'src/pages/Decks'),
            '@documentation': path.resolve(
                __dirname,
                'src/pages/Documentation'
            ),
            '@extract': path.resolve(__dirname, 'src/pages/Extract'),
            '@groups': path.resolve(__dirname, 'src/pages/Groups'),
            '@landingpage': path.resolve(__dirname, 'src/pages/LandingPage'),
            '@layouts': path.resolve(__dirname, 'src/pages/layouts'),
            '@legal': path.resolve(__dirname, 'src/pages/Legal'),
            '@main': path.resolve(__dirname, 'src/pages/Main'),
            '@play': path.resolve(__dirname, 'src/pages/Play'),
            '@quiz': path.resolve(__dirname, 'src/pages/Quiz'),
            '@quizzes': path.resolve(__dirname, 'src/pages/Quizzes'),
            '@study': path.resolve(__dirname, 'src/pages/Study'),
            '@terms': path.resolve(__dirname, 'src/pages/Terms'),
            '@upgrade': path.resolve(__dirname, 'src/pages/Upgrade'),
            '@utils': path.resolve(__dirname, 'src/lib/utils'),
            '@contexts': path.resolve(__dirname, 'src/lib/contexts'),
            '@services': path.resolve(__dirname, 'src/lib/services'),
            '@hooks': path.resolve(__dirname, 'src/lib/hooks'),
            '@store': path.resolve(__dirname, 'src/lib/store'),
            '@common': path.resolve(__dirname, 'src/common'),
            '@customTypes': path.resolve(__dirname, 'src/types'),
            '@routes': path.resolve(__dirname, 'src/routes'),
            '@client': path.resolve(__dirname, 'src/client'),
        },
    },

    build: {
        sourcemap: true,
        // assetsInclude: ['**/*.ttf'],
    },
    // publicDir: 'public',
})
