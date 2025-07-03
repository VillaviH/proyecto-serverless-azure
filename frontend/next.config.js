/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    appDir: true,
  },
  // Configuración para Azure Static Web Apps
  output: 'export',
  trailingSlash: true,
  images: {
    unoptimized: true
  },
  // Configuración para producción
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL,
  },
}

module.exports = nextConfig