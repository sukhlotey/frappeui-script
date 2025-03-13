#!/bin/bash

set -e

PROJECT_NAME="${1:-client}"

echo "Starting frontend setup for $PROJECT_NAME..."

echo "Creating Vue project..."
npm create vue@latest "$PROJECT_NAME" -- --default || {
    echo "Error: Failed to create Vue project. Check the npm logs for details (e.g., ~/.npm/_logs/)."
    exit 1
}

cd "$PROJECT_NAME" || {
    echo "Error: Failed to navigate to project directory $PROJECT_NAME."
    exit 1
}

echo "Installing TailwindCSS dependencies..."
npm install -D tailwindcss postcss autoprefixer @tailwindcss/postcss || {
    echo "Error: Failed to install TailwindCSS dependencies."
    exit 1
}

echo "Initializing TailwindCSS configuration..."
npx tailwindcss init || {
    echo "Error: Failed to initialize TailwindCSS configuration."
    exit 1
}

echo "Configuring tailwind.config.js..."
cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{vue,js,ts,jsx,tsx}'],
  theme: {
    extend: {},
  },
  plugins: [],
};
EOF

echo "Creating TailwindCSS directives file..."
mkdir -p src/assets
cat > src/assets/tailwind.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF

echo "Updating src/main.js to include TailwindCSS..."
cat > src/main.js << 'EOF'
import { createApp } from 'vue';
import App from './App.vue';
import './assets/tailwind.css';

createApp(App).mount('#app');
EOF

echo "Creating postcss.config.cjs..."
cat > postcss.config.cjs << 'EOF'
module.exports = {
  plugins: {
    '@tailwindcss/postcss': {},
    autoprefixer: {},
  },
};
EOF

echo "Installing FrappeUI..."
npm install frappe-ui || {
    echo "Error: Failed to install FrappeUI."
    exit 1
}

echo "Updating tailwind.config.js for FrappeUI integration..."
cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
import tailwindConfig from "frappe-ui/src/utils/tailwind.config";

export default {
  presets: [tailwindConfig],
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
    "./node_modules/frappe-ui/src/components/**/*.{vue,js,ts,jsx,tsx}",
    "../node_modules/frappe-ui/src/components/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};
EOF

echo "Updating vite.config.js for FrappeUI integration..."
cat > vite.config.js << 'EOF'
import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'

export default defineConfig({
  plugins: [
    vue(),
    vueDevTools(),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    },
  },
  optimizeDeps: {
    include: ["frappe-ui > feather-icons", "showdown", "engine.io-client"],
  },
})
EOF

echo "Frontend setup complete! You can now run 'npm run dev' to start the development server."
