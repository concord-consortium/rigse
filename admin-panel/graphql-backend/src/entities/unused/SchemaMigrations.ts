import { Column, Entity, Index } from "typeorm";

@Index("unique_schema_migrations", ["version"], { unique: true })
@Entity("schema_migrations", { schema: "portal_development" })
export class SchemaMigrations {
  @Column("varchar", { name: "version", length: 255 })
  version: string;
}
