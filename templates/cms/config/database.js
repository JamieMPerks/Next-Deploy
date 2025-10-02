// cms/config/database.js
module.exports = ({ env }) => ({
  connection: {
    client: env("DATABASE_CLIENT", "postgres"),
    connection: {
      host: env("DATABASE_HOST", "postgres"),
      port: env.int("DATABASE_PORT", 5432),
      database: env("DATABASE_NAME", "app"),
      user: env("DATABASE_USERNAME", "app"),
      password: env("DATABASE_PASSWORD", "changeme"),
      ssl: env.bool("DATABASE_SSL", false),
    },
    debug: false,
  },
});
