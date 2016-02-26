CREATE UNIQUE INDEX  "index_tags_on_name" ON "tags"  ("name");
DROP INDEX "index_taggings_on_tag_id";
DROP INDEX "index_taggings_on_taggable_id_and_taggable_type_and_context";
CREATE UNIQUE INDEX  "taggings_idx" ON "taggings"  ("tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type");
INSERT INTO schema_migrations (version) VALUES (20160218193223);
