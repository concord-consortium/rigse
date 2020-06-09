import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_portal_districts_on_nces_district_id", ["ncesDistrictId"], {})
@Index("index_portal_districts_on_state", ["state"], {})
@Entity("portal_districts", { schema: "portal_development" })
export class PortalDistricts {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("mediumtext", { name: "description", nullable: true })
  description: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("int", { name: "nces_district_id", nullable: true })
  ncesDistrictId: number | null;

  @Column("varchar", { name: "state", nullable: true, length: 2 })
  state: string | null;

  @Column("varchar", { name: "leaid", nullable: true, length: 7 })
  leaid: string | null;

  @Column("varchar", { name: "zipcode", nullable: true, length: 5 })
  zipcode: string | null;
}
