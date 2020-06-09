import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_portal_teacher_clazzes_on_clazz_id", ["clazzId"], {})
@Index("index_portal_teacher_clazzes_on_teacher_id", ["teacherId"], {})
@Entity("portal_teacher_clazzes", { schema: "portal_development" })
export class PortalTeacherClazzes {
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

  @Column("int", { name: "teacher_id", nullable: true })
  teacherId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("tinyint", {
    name: "active",
    nullable: true,
    width: 1,
    default: () => "'1'",
  })
  active: boolean | null;

  @Column("int", { name: "position", nullable: true, default: () => "'0'" })
  position: number | null;
}
