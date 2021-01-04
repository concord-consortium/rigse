import { Column, Entity } from "typeorm";

@Entity("portal_courses_grade_levels", { schema: "portal_development" })
export class PortalCoursesGradeLevels {
  @Column("int", { name: "grade_level_id", nullable: true })
  gradeLevelId: number | null;

  @Column("int", { name: "course_id", nullable: true })
  courseId: number | null;
}
