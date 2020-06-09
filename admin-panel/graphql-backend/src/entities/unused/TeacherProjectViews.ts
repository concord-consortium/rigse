import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_teacher_project_views_on_teacher_id", ["teacherId"], {})
@Entity("teacher_project_views", { schema: "portal_development" })
export class TeacherProjectViews {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "viewed_project_id" })
  viewedProjectId: number;

  @Column("int", { name: "teacher_id" })
  teacherId: number;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
