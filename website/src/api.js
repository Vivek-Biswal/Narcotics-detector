import { createClient } from '@supabase/supabase-js';
import { supabaseUrl, supabaseKey } from './config';
import { isNative } from './platform';
import { nativeAuthRedirect, parseAuthCallback } from './oauth';
import { App } from '@capacitor/app';
import { Browser } from '@capacitor/browser';

export const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: { flowType: isNative ? 'pkce' : 'implicit', detectSessionInUrl: !isNative },
});

const pendingKey = 'narctrace-google-pending';
let processingCallback = false;
export async function initializeNativeAuth(onError) {
  if (!isNative) return;
  const consume = async value => {
    const callback = parseAuthCallback(value);
    if (!callback || processingCallback) return;
    const started = Number(localStorage.getItem(pendingKey));
    if (!started || Date.now() - started > 30 * 60 * 1000) {
      onError('This sign-in link has expired. Please start Google sign-in again.');
      return;
    }
    processingCallback = true;
    try {
      if (callback.error) throw new Error(callback.error);
      const { error } = await supabase.auth.exchangeCodeForSession(callback.code);
      if (error) throw new Error('Google sign-in could not be completed. Please start again.');
    } catch (error) { onError(error.message); }
    finally {
      localStorage.removeItem(pendingKey);
      processingCallback = false;
      await Browser.close().catch(() => {});
    }
  };
  await App.addListener('appUrlOpen', ({ url }) => { void consume(url); });
  const launch = await App.getLaunchUrl();
  if (launch?.url) await consume(launch.url);
}

export async function getRecords(userId) {
  const { data, error } = await supabase.from('tests').select('*').eq('operator_id', userId)
    .order('captured_at', { ascending: false }).limit(500);
  if (error) throw error;
  return data;
}

export async function signIn(email, password) {
  const { data, error } = await supabase.auth.signInWithPassword({ email, password });
  if (error) throw error;
  return data;
}

export async function googleSignIn() {
  const response = await fetch(`${supabaseUrl}/auth/v1/settings`, { headers: { apikey: supabaseKey }, signal: AbortSignal.timeout(15000) });
  if (!response.ok) throw new Error('Unable to reach sign-in. Please try again.');
  const settings = await response.json();
  if (!settings.external?.google) throw new Error('Google sign-in needs to be enabled by your project administrator. Email sign-in and the preview are available.');
  const { data, error } = await supabase.auth.signInWithOAuth({ provider: 'google', options: {
    redirectTo: isNative ? nativeAuthRedirect : `${location.origin}/`,
    skipBrowserRedirect: isNative,
  } });
  if (error) throw error;
  if (isNative) {
    if (!data.url) throw new Error('Google sign-in is unavailable. Please try again.');
    localStorage.setItem(pendingKey, String(Date.now()));
    try { await Browser.open({ url: data.url }); }
    catch (error) { localStorage.removeItem(pendingKey); throw error; }
  }
}
