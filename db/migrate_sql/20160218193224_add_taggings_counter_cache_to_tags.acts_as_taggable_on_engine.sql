ALTER TABLE "tags" ADD COLUMN "taggings_count" integer DEFAULT 0;
INSERT INTO schema_migrations (version) VALUES (20160218193224);
