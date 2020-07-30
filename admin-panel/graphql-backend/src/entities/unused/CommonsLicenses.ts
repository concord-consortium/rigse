import { Column, Entity, Index, PrimaryColumn } from "typeorm";

@Index("index_commons_licenses_on_code", ["code"], {})
@Entity("commons_licenses", { schema: "portal_development" })
export class CommonsLicenses {
  @PrimaryColumn("varchar", { name: "code", length: 255 })
  code: string;

  @Column("varchar", { name: "name", length: 255 })
  name: string;

  @Column("mediumtext", { name: "description", nullable: true })
  description: string | null;

  @Column("varchar", { name: "deed", nullable: true, length: 255 })
  deed: string | null;

  @Column("varchar", { name: "legal", nullable: true, length: 255 })
  legal: string | null;

  @Column("varchar", { name: "image", nullable: true, length: 255 })
  image: string | null;

  @Column("int", { name: "number", nullable: true })
  number: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
