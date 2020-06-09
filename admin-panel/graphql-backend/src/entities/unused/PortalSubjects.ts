import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("portal_subjects", { schema: "portal_development" })
export class PortalSubjects {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("mediumtext", { name: "description", nullable: true })
  description: string | null;

  @Column("int", { name: "teacher_id", nullable: true })
  teacherId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
