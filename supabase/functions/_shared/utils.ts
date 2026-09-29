import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';

export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

export function getSupabaseClient() {
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
  
  return createClient(supabaseUrl, supabaseServiceKey);
}

export function canonicalizeRecord(record: any): string {
  // Sort keys to ensure deterministic ordering
  const keys = Object.keys(record).sort();
  const canonicalObj: Record<string, any> = {};
  for (const key of keys) {
    if (record[key] !== null && record[key] !== undefined) {
      canonicalObj[key] = record[key];
    }
  }
  return JSON.stringify(canonicalObj);
}

export async function sha256(message: string | Uint8Array | ArrayBuffer): Promise<string> {
  const data = typeof message === 'string' ? new TextEncoder().encode(message) : message;
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

export async function generateSignature(recordHash: string, secret: string): Promise<string> {
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  
  const signature = await crypto.subtle.sign(
    'HMAC',
    key,
    encoder.encode(recordHash)
  );
  
  const signatureArray = Array.from(new Uint8Array(signature));
  return signatureArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

export async function verifySignature(recordHash: string, signature: string, secret: string): Promise<boolean> {
  const expectedSignature = await generateSignature(recordHash, secret);
  return signature === expectedSignature;
}
