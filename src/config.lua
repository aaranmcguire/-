local config = require "lapis.config"

-- Database connection settings.
config({"development", "production"}, {
  postgres = {
    host = "127.0.0.1",
    user = "fiber",
    password = "fiber",
    database = "fiber"
  }
})