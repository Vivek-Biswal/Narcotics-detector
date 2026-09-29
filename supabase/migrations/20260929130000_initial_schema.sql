-- 1. ENUMs
CREATE TYPE test_result AS ENUM ('NEGATIVE', 'POSITIVE', 'INCONCLUSIVE');
CREATE TYPE test_verification_status AS ENUM ('PENDING', 'VALID', 'INVALID', 'INTEGRITY_FAILED');

-- 2. Tables

-- A. profiles
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    operator_id TEXT UNIQUE NOT NULL,
    full_name TEXT,
    role TEXT,
    organization TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- B. tests
CREATE TABLE tests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    test_id TEXT UNIQUE,
    operator_id UUID REFERENCES profiles(id),
    result test_result NOT NULL,
    result_confidence NUMERIC,
    classification_method TEXT,
    captured_at TIMESTAMPTZ NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    location_accuracy DOUBLE PRECISION,
    image_storage_path TEXT,
    image_sha256 TEXT NOT NULL,
    record_hash TEXT,
    signature TEXT,
    signature_algorithm TEXT,
    verification_status test_verification_status DEFAULT 'PENDING',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- C. test_images
CREATE TABLE test_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    test_id UUID REFERENCES tests(id) ON DELETE CASCADE,
    storage_path TEXT NOT NULL,
    sha256 TEXT NOT NULL,
    file_size BIGINT,
    mime_type TEXT,
    width INTEGER,
    height INTEGER,
    captured_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- D. verification_logs
CREATE TABLE verification_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    test_id UUID REFERENCES tests(id) ON DELETE CASCADE,
    verifier_id UUID REFERENCES profiles(id),
    verification_result TEXT NOT NULL,
    image_hash_match BOOLEAN,
    signature_valid BOOLEAN,
    record_hash_match BOOLEAN,
    verified_at TIMESTAMPTZ DEFAULT now(),
    metadata JSONB
);

-- E. audit_logs
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES profiles(id),
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. TEST ID GENERATION
CREATE SEQUENCE test_id_seq START 1;
CREATE OR REPLACE FUNCTION generate_test_id()
RETURNS TEXT AS $$
BEGIN
    RETURN 'TEST-' || to_char(CURRENT_DATE, 'YYYY') || '-' || lpad(nextval('test_id_seq')::text, 6, '0');
END;
$$ LANGUAGE plpgsql;

-- Use trigger to automatically assign test_id if not provided
CREATE OR REPLACE FUNCTION trigger_set_test_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.test_id IS NULL THEN
        NEW.test_id := generate_test_id();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_test_id_trigger
BEFORE INSERT ON tests
FOR EACH ROW
EXECUTE FUNCTION trigger_set_test_id();

-- Triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tests_updated_at BEFORE UPDATE ON tests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 4. RLS POLICIES

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE test_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Profiles: Authenticated users can read profiles, can only update own
CREATE POLICY "Authenticated users can read profiles" ON profiles
    FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Tests: 
CREATE POLICY "Users can insert own tests" ON tests
    FOR INSERT WITH CHECK (auth.uid() = operator_id);
CREATE POLICY "Users can view own tests" ON tests
    FOR SELECT USING (auth.uid() = operator_id);
-- Allow viewing if verifying
CREATE POLICY "Verifiers can view tests" ON tests
    FOR SELECT USING (auth.role() = 'authenticated');

-- We don't allow UPDATE on tests by client directly to protect signatures/hashes
-- Except maybe for specific fields? We just deny UPDATE for clients.
-- Service role can still update.
CREATE POLICY "Users cannot update tests directly" ON tests
    FOR UPDATE USING (false);

-- Test Images:
CREATE POLICY "Users can view test images" ON test_images
    FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Users can insert own test images" ON test_images
    FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM tests WHERE tests.id = test_images.test_id AND tests.operator_id = auth.uid()));

-- Verification Logs:
CREATE POLICY "Users can insert verification logs" ON verification_logs
    FOR INSERT WITH CHECK (auth.uid() = verifier_id);
CREATE POLICY "Users can view verification logs" ON verification_logs
    FOR SELECT USING (auth.role() = 'authenticated');

-- Audit Logs:
CREATE POLICY "Users can insert own audit logs" ON audit_logs
    FOR INSERT WITH CHECK (auth.uid() = actor_id);
CREATE POLICY "Users can view own audit logs" ON audit_logs
    FOR SELECT USING (auth.uid() = actor_id);

-- 5. STORAGE BUCKET
INSERT INTO storage.buckets (id, name, public) VALUES ('test-images', 'test-images', false) ON CONFLICT (id) DO NOTHING;

-- Storage RLS
CREATE POLICY "Users can upload their own test images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'test-images' AND 
        auth.uid() = (string_to_array(name, '/'))[1]::uuid
    );

CREATE POLICY "Users can view their own test images" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'test-images' AND 
        auth.uid() = (string_to_array(name, '/'))[1]::uuid
    );
