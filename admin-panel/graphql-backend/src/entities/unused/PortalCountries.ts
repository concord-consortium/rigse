import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_portal_countries_on_iso_id", ["isoId"], {})
@Index("index_portal_countries_on_name", ["name"], {})
@Index("index_portal_countries_on_two_letter", ["twoLetter"], {})
@Entity("portal_countries", { schema: "portal_development" })
export class PortalCountries {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("varchar", { name: "formal_name", nullable: true, length: 255 })
  formalName: string | null;

  @Column("varchar", { name: "capital", nullable: true, length: 255 })
  capital: string | null;

  @Column("varchar", { name: "two_letter", nullable: true, length: 2 })
  twoLetter: string | null;

  @Column("varchar", { name: "three_letter", nullable: true, length: 3 })
  threeLetter: string | null;

  @Column("varchar", { name: "tld", nullable: true, length: 255 })
  tld: string | null;

  @Column("int", { name: "iso_id", nullable: true })
  isoId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
