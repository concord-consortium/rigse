import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("portal_grade_levels", { schema: "portal_development" })
export class PortalGradeLevels {
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

  @Column("int", { name: "has_grade_levels_id", nullable: true })
  hasGradeLevelsId: number | null;

  @Column("varchar", {
    name: "has_grade_levels_type",
    nullable: true,
    length: 255,
  })
  hasGradeLevelsType: string | null;

  @Column("int", { name: "grade_id", nullable: true })
  gradeId: number | null;
}
