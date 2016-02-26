CREATE TABLE "c_ratings" ("id" serial primary key, "user_id" integer, "comment_id" integer, "score" integer, "created_at" timestamp, "updated_at" timestamp) ;
INSERT INTO schema_migrations (version) VALUES (20160222142426);
