ALTER TABLE "monsters" ADD COLUMN "votes_count" integer;
INSERT INTO schema_migrations (version) VALUES (20160217213055);
