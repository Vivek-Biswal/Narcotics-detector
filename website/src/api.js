import { createClient } from '@supabase/supabase-js';
import { supabaseUrl, supabaseKey } from './config';

export const supabase = createClient(supabaseUrl, supabaseKey);

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
  const response = await fetch(`${supabaseUrl}/auth/v1/settings`, { headers: { apikey: supabaseKey } });
  if (!response.ok) throw new Error('Unable to reach sign-in. Please try again.');
  const settings = await response.json();
  if (!settings.external?.google) throw new Error('Google sign-in needs to be enabled by your project administrator. Email sign-in and the preview are available.');
  const { error } = await supabase.auth.signInWithOAuth({ provider: 'google', options: { redirectTo: `${location.origin}/` } });
  if (error) throw error;
}
