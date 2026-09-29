import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { corsHeaders, getSupabaseClient, canonicalizeRecord, sha256, generateSignature } from '../_shared/utils.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { test_id } = await req.json();
    if (!test_id) {
      throw new Error('test_id is required');
    }

    const supabase = getSupabaseClient();

    // 1. Fetch test record
    const { data: testRecord, error: fetchError } = await supabase
      .from('tests')
      .select('*')
      .eq('id', test_id)
      .single();

    if (fetchError || !testRecord) {
      throw new Error(`Test record not found: ${fetchError?.message}`);
    }
    
    if (testRecord.signature) {
       return new Response(JSON.stringify({ error: 'Record is already signed' }), {
         status: 400,
         headers: { ...corsHeaders, 'Content-Type': 'application/json' }
       });
    }

    // 2. Fetch image from storage securely
    const { data: imageBlob, error: downloadError } = await supabase
      .storage
      .from('test-images')
      .download(testRecord.image_storage_path);

    if (downloadError || !imageBlob) {
      throw new Error(`Failed to download image: ${downloadError?.message}`);
    }

    // 3. Calculate SHA-256 of the image
    const imageArrayBuffer = await imageBlob.arrayBuffer();
    const calculatedImageHash = await sha256(imageArrayBuffer);

    // 4. Compare with submitted hash
    if (calculatedImageHash !== testRecord.image_sha256) {
      // Update record to INTEGRITY_FAILED
      await supabase
        .from('tests')
        .update({ verification_status: 'INTEGRITY_FAILED' })
        .eq('id', test_id);
        
      return new Response(JSON.stringify({
        success: false,
        message: 'Image hash mismatch. Integrity failed.',
        calculated_hash: calculatedImageHash,
        stored_hash: testRecord.image_sha256
      }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 });
    }

    // 5. Create digital record for signing
    // The canonical representation contains specific fields
    const recordToSign = {
      test_id: testRecord.test_id,
      result: testRecord.result,
      operator_id: testRecord.operator_id,
      captured_at: testRecord.captured_at,
      latitude: testRecord.latitude,
      longitude: testRecord.longitude,
      image_sha256: testRecord.image_sha256,
      classification_method: testRecord.classification_method,
      created_at: testRecord.created_at
    };

    const canonicalString = canonicalizeRecord(recordToSign);
    const recordHash = await sha256(canonicalString);

    // 6. Sign the canonical string
    const signingSecret = Deno.env.get('SIGNING_SECRET') ?? 'default_dev_secret_change_in_prod';
    const signature = await generateSignature(recordHash, signingSecret);

    // 7. Update the tests row
    const { error: updateError } = await supabase
      .from('tests')
      .update({
        record_hash: recordHash,
        signature: signature,
        signature_algorithm: 'HMAC-SHA256',
        verification_status: 'VALID'
      })
      .eq('id', test_id);

    if (updateError) {
      throw new Error(`Failed to update test record: ${updateError.message}`);
    }

    return new Response(
      JSON.stringify({ success: true, message: 'Record signed successfully', record_hash: recordHash }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (error: any) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    );
  }
});
