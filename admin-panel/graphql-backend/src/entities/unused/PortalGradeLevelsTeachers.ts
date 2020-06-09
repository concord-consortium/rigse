import { Column, Entity } from "typeorm";

@Entity("portal_grade_levels_teachers", { schema: "portal_development" })
export class PortalGradeLevelsTeachers {
  @Column("int", { name: "grade_level_id", nullable: true })
  gradeLevelId: number | null;

  @Column("int", { name: "teacher_id", nullable: true })
  teacherId: number | null;
}
