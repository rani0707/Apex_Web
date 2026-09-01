/**
 * URL safety helpers used across components that render external links
 * sourced from JSON. Centralised so every external href passes through the
 * same allow-list before reaching the DOM.
 */

const DEFAULT_ALLOWED_HOSTS = new Set<string>([
  'github.com',
  'www.github.com',
  'docs.google.com',
  'forms.gle',
  'forms.google.com',
  'mju-apex.github.io',
]);

/**
 * Returns a sanitized https URL if `value` is safe to render as a hyperlink.
 * Returns null for anything we cannot safely link to (empty, non-https,
 * unknown host, javascript:/data:/vbscript: schemes).
 */
export function sanitizeExternalUrl(
  value: string | null | undefined,
  allowedHosts: ReadonlySet<string> = DEFAULT_ALLOWED_HOSTS,
): string | null {
  if (!value) return null;
  const trimmed = value.trim();
  if (!trimmed) return null;

  let parsed: URL;
  try {
    parsed = new URL(trimmed);
  } catch {
    return null;
  }

  if (parsed.protocol !== 'https:') return null;
  if (parsed.username || parsed.password) return null;
  if (allowedHosts.size > 0 && !allowedHosts.has(parsed.hostname.toLowerCase())) {
    return null;
  }

  // Strip credentials and fragments that could carry payloads
  return parsed.toString();
}

/**
 * Returns a sanitized mailto: href if `value` looks like a valid email.
 * Returns null otherwise.
 */
export function sanitizeMailto(value: string | null | undefined): string | null {
  if (!value) return null;
  const trimmed = value.trim();
  if (!trimmed) return null;
  // RFC 5322 light-weight check; full validation isn't needed for href rendering
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(trimmed)) return null;
  return `mailto:${trimmed}`;
}