ALTER TABLE "users" ADD COLUMN "username" character varying(255);
CREATE UNIQUE INDEX  "index_users_on_username" ON "users"  ("username");
INSERT INTO schema_migrations (version) VALUES (20160216153040);
