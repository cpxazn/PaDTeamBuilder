CREATE TABLE "tags" ("id" serial primary key, "name" character varying(255)) ;
CREATE TABLE "taggings" ("id" serial primary key, "tag_id" integer, "taggable_id" integer, "taggable_type" character varying(255), "tagger_id" integer, "tagger_type" character varying(255), "context" character varying(128), "created_at" timestamp) ;
CREATE  INDEX  "index_taggings_on_tag_id" ON "taggings"  ("tag_id");
CREATE  INDEX  "index_taggings_on_taggable_id_and_taggable_type_and_context" ON "taggings"  ("taggable_id", "taggable_type", "context");
INSERT INTO schema_migrations (version) VALUES (20160218193222);
