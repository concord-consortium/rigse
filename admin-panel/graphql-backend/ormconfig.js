const env = process.env;
const {DB_HOST, MYSQL_USER, MYSQL_ROOT_PASSWORD} = env;

const config = {
  "type": "mysql",
  "host": DB_HOST,
  "port": 3306,
  "username": MYSQL_USER,
  "password": MYSQL_ROOT_PASSWORD,
  "database": "portal_development",
  "entities": ["./src/entities/*.ts"],
  "migrationsTableName": "custom_migration_table",
  "migrations": ["migration/*.js"],
  "cli": {
      "migrationsDir": "migration"
  }
}

module.exports=config
