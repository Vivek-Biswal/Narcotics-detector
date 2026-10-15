export const nativeAuthRedirect = 'in.etaernal.narctrace://auth/callback';

export function parseAuthCallback(value) {
  let url;
  try { url = new URL(value); } catch { return null; }
  if (url.protocol !== 'in.etaernal.narctrace:' || url.host !== 'auth' || url.pathname !== '/callback') return null;
  if (url.searchParams.has('error')) return { error: 'Google sign-in was cancelled or declined. Please try again.' };
  const code = url.searchParams.get('code');
  return code ? { code } : { error: 'The sign-in link is incomplete. Please start Google sign-in again.' };
}
