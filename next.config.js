/** @type {import('next').NextConfig} */
const nextConfig = {
  poweredByHeader: false,
  // NOTE: output: 'standalone' is intentionally omitted because Next.js 16
  // does not generate .next/standalone during webpack builds. The Docker
  // image instead ships the full .next directory and runs `next start`.
  reactStrictMode: true,

  // Only redirect when actually behind a proxy that sets x-forwarded-proto.
  // Using temporary (307) so we can roll back without poisoning browser caches.
  async redirects() {
    return [
      {
        source: '/:path*',
        has: [{ type: 'header', key: 'x-forwarded-proto', value: 'http' }],
        destination: 'https://:host/:path*',
        permanent: false,
        statusCode: 307,
      },
    ];
  },

  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          { key: 'X-DNS-Prefetch-Control', value: 'on' },
          { key: 'X-Frame-Options', value: 'SAMEORIGIN' },
          { key: 'X-Content-Type-Options', value: 'nosniff' },
          { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
          {
            key: 'Permissions-Policy',
            value:
              'camera=(), microphone=(), geolocation=(), interest-cohort=(), payment=(), usb=(), screen-wake-lock=(), xr-spatial-tracking=()',
          },
          // 2-year HSTS with subdomains + preload-ready.
          // Only enable after confirming HTTPS works end-to-end.
          {
            key: 'Strict-Transport-Security',
            value: 'max-age=63072000; includeSubDomains',
          },
          {
            key: 'Content-Security-Policy',
            value: [
              "default-src 'self' https:",
              // 'unsafe-inline' is needed for Next.js inline boot scripts in this setup;
              // tighten further by switching to nonce-based CSP if requirements allow.
              // static.cloudflareinsights.com is required because Cloudflare
              // Web Analytics injects its beacon script at the edge.
              "script-src 'self' 'unsafe-inline' https://static.cloudflareinsights.com",
              "script-src-elem 'self' 'unsafe-inline' https://static.cloudflareinsights.com",
              "style-src 'self' 'unsafe-inline'",
              "img-src 'self' data: https:",
              "font-src 'self' data:",
              "connect-src 'self' https:",
              "frame-src 'self' https://docs.google.com https://forms.google.com",
              "frame-ancestors 'self'",
              "form-action 'self'",
              "base-uri 'self'",
              "object-src 'none'",
              'upgrade-insecure-requests',
            ].join('; '),
          },
        ],
      },
    ];
  },
};

module.exports = nextConfig;