DROP DATABASE IF EXISTS gitea;
CREATE DATABASE gitea CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_unicode_ci';
GRANT ALL PRIVILEGES ON gitea.* TO 'gitea';
FLUSH PRIVILEGES;
exit