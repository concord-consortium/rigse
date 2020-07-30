import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_portal_schools_on_country_id", ["countryId"], {})
@Index("index_portal_schools_on_district_id", ["districtId"], {})
@Index("index_portal_schools_on_nces_school_id", ["ncesSchoolId"], {})
@Index("index_portal_schools_on_state", ["state"], {})
@Index("index_portal_schools_on_name", ["name"], {})
@Entity("portal_schools", { schema: "portal_development" })
export class PortalSchools {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("mediumtext", { name: "description", nullable: true })
  description: string | null;

  @Column("int", { name: "district_id", nullable: true })
  districtId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("int", { name: "nces_school_id", nullable: true })
  ncesSchoolId: number | null;

  @Column("varchar", { name: "state", nullable: true, length: 80 })
  state: string | null;

  @Column("varchar", { name: "zipcode", nullable: true, length: 20 })
  zipcode: string | null;

  @Column("varchar", { name: "ncessch", nullable: true, length: 12 })
  ncessch: string | null;

  @Column("int", { name: "country_id", nullable: true })
  countryId: number | null;

  @Column("mediumtext", { name: "city", nullable: true })
  city: string | null;
}
