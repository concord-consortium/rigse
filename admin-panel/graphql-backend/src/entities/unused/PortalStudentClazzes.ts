import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_portal_student_clazzes_on_clazz_id", ["clazzId"], {})
@Index("student_class_index", ["studentId", "clazzId"], {})
@Entity("portal_student_clazzes", { schema: "portal_development" })
export class PortalStudentClazzes {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("mediumtext", { name: "description", nullable: true })
  description: string | null;

  @Column("datetime", { name: "start_time", nullable: true })
  startTime: Date | null;

  @Column("datetime", { name: "end_time", nullable: true })
  endTime: Date | null;

  @Column("int", { name: "clazz_id", nullable: true })
  clazzId: number | null;

  @Column("int", { name: "student_id", nullable: true })
  studentId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
