import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_portal_clazzes_on_class_word", ["classWord"], { unique: true })
@Entity("portal_clazzes", { schema: "portal_development" })
export class PortalClazzes {
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

  @Column("varchar", {
    name: "class_word",
    nullable: true,
    unique: true,
    length: 255,
  })
  classWord: string | null;

  @Column("varchar", { name: "status", nullable: true, length: 255 })
  status: string | null;

  @Column("int", { name: "course_id", nullable: true })
  courseId: number | null;

  @Column("int", { name: "semester_id", nullable: true })
  semesterId: number | null;

  @Column("int", { name: "teacher_id", nullable: true })
  teacherId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("varchar", { name: "section", nullable: true, length: 255 })
  section: string | null;

  @Column("tinyint", {
    name: "default_class",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  defaultClass: boolean | null;

  @Column("tinyint", {
    name: "logging",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  logging: boolean | null;

  @Column("varchar", { name: "class_hash", nullable: true, length: 48 })
  classHash: string | null;
}
