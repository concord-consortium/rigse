import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("import_school_district_mappings", { schema: "portal_development" })
export class ImportSchoolDistrictMappings {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "district_id", nullable: true })
  districtId: number | null;

  @Column("varchar", {
    name: "import_district_uuid",
    nullable: true,
    length: 255,
  })
  importDistrictUuid: string | null;
}
