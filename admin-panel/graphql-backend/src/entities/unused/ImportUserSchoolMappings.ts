import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("import_user_school_mappings", { schema: "portal_development" })
export class ImportUserSchoolMappings {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "school_id", nullable: true })
  schoolId: number | null;

  @Column("varchar", { name: "import_school_url", nullable: true, length: 255 })
  importSchoolUrl: string | null;
}
