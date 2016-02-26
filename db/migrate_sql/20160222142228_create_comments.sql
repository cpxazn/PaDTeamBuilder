CREATE TABLE "comments" ("id" serial primary key, "user_id" integer, "leader_id" integer, "sub_id" integer, "comment" text, "parent_id" integer, "created_at" timestamp, "updated_at" timestamp) ;
INSERT INTO schema_migrations (version) VALUES (20160222142228);
