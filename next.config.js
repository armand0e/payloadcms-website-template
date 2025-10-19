import { withPayload } from '@payloadcms/next/withPayload'

import redirects from './redirects.js'

const NEXT_PUBLIC_SERVER_URL = process.env.VERCEL_PROJECT_PRODUCTION_URL
  ? `https://${process.env.VERCEL_PROJECT_PRODUCTION_URL}`
  : undefined || process.env.NEXT_PUBLIC_SERVER_URL || 'http://localhost:3000'

const remotePatterns = []

if (NEXT_PUBLIC_SERVER_URL) {
  const url = new URL(NEXT_PUBLIC_SERVER_URL)

  remotePatterns.push({
    hostname: url.hostname,
    protocol: url.protocol.replace(':', ''),
  })
}

/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    reactCompiler: true,
  },
  output: 'standalone',
  images: {
    remotePatterns: [...remotePatterns /* 'https://example.com' */],
  },
  reactStrictMode: true,
  redirects,
}

export default withPayload(nextConfig)
