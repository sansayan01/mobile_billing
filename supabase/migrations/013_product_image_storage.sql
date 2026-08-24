-- Migration 013: Create product-images storage bucket
-- Enables image upload for products with public read access

-- Create product-images storage bucket (public)
INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO NOTHING;

-- Allow authenticated users to upload images
CREATE POLICY "Allow authenticated uploads to product-images"
  ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'product-images');

-- Allow public read access to product images
CREATE POLICY "Allow public read on product-images"
  ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'product-images');

-- Allow authenticated users to update their own uploads
CREATE POLICY "Allow authenticated updates on product-images"
  ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'product-images');

-- Allow authenticated users to delete their own uploads
CREATE POLICY "Allow authenticated deletes on product-images"
  ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'product-images');
