-- Migration 014: Add icon and color fields to categories table

ALTER TABLE categories
  ADD COLUMN IF NOT EXISTS icon_code_point INTEGER DEFAULT 58713, -- Icons.category_outlined
  ADD COLUMN IF NOT EXISTS color_value INTEGER DEFAULT 16751394; -- 0xFF6750A4 (Material purple)

CREATE INDEX IF NOT EXISTS idx_categories_color ON categories(color_value);
