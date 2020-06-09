import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_portal_students_on_user_id", ["userId"], {})
@Entity("portal_students", { schema: "portal_development" })
export class PortalStudents {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("int", { name: "grade_level_id", nullable: true })
  gradeLevelId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
