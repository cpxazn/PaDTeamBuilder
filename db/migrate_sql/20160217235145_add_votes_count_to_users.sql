ALTER TABLE "users" ADD COLUMN "votes_count" integer;
INSERT INTO schema_migrations (version) VALUES (20160217235145);
