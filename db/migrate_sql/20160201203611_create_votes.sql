CREATE TABLE "votes" ("id" serial primary key, "score" integer, "leader_id" integer, "sub_id" integer, "user_id" integer, "created_at" timestamp, "updated_at" timestamp) ;
INSERT INTO schema_migrations (version) VALUES (20160201203611);
