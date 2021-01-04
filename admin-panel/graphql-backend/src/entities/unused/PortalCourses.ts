import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_portal_courses_on_course_number", ["courseNumber"], {})
@Index("index_portal_courses_on_name", ["name"], {})
@Index("index_portal_courses_on_school_id", ["schoolId"], {})
@Entity("portal_courses", { schema: "portal_development" })
export class PortalCourses {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("mediumtext", { name: "description", nullable: true })
  description: string | null;

  @Column("int", { name: "school_id", nullable: true })
  schoolId: number | null;

  @Column("varchar", { name: "status", nullable: true, length: 255 })
  status: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("varchar", { name: "course_number", nullable: true, length: 255 })
  courseNumber: string | null;
}
