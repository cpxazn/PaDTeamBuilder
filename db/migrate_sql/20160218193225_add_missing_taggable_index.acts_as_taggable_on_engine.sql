CREATE  INDEX  "index_taggings_on_taggable_id_and_taggable_type_and_context" ON "taggings"  ("taggable_id", "taggable_type", "context");
INSERT INTO schema_migrations (version) VALUES (20160218193225);
