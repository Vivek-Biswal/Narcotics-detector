import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { corsHeaders, getSupabaseClient, canonicalizeRecord, sha256, verifySignature } from '../_shared/utils.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // The request should provide the test_id, and optionally an auth header for the verifier
    const { test_id, verifier_id } = await req.json();
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
    
    if (!testRecord.signature) {
       return new Response(JSON.stringify({ error: 'Record is not signed yet' }), {
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

    // 4. Check Image Hash Match
    const imageHashMatch = (calculatedImageHash === testRecord.image_sha256);

    // 5. Recreate canonical string and check Record Hash
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
    const calculatedRecordHash = await sha256(canonicalString);
    const recordHashMatch = (calculatedRecordHash === testRecord.record_hash);

    // 6. Verify the Signature
    const signingSecret = Deno.env.get('SIGNING_SECRET') ?? 'default_dev_secret_change_in_prod';
    const isSignatureValid = await verifySignature(testRecord.record_hash, testRecord.signature, signingSecret);

    // 7. Determine overall verification result
    let verification_result = 'VALID';
    if (!imageHashMatch || !recordHashMatch || !isSignatureValid) {
        verification_result = 'INTEGRITY_FAILED';
    }
    
    // Log verification
    if (verifier_id) {
       await supabase.from('verification_logs').insert({
         test_id: testRecord.id,
         verifier_id: verifier_id,
         verification_result: verification_result,
         image_hash_match: imageHashMatch,
         signature_valid: isSignatureValid,
         record_hash_match: recordHashMatch,
         metadata: { calculated_image_hash: calculatedImageHash, calculated_record_hash: calculatedRecordHash }
       });
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        verification_result,
        details: {
            image_hash_match: imageHashMatch,
            signature_valid: isSignatureValid,
            record_hash_match: recordHashMatch
        }
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (error: any) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    );
  }
});
