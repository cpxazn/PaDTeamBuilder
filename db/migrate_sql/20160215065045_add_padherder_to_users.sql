ALTER TABLE "users" ADD COLUMN "padherder" character varying(255);
INSERT INTO schema_migrations (version) VALUES (20160215065045);
