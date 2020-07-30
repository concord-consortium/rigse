import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index(
  "index_sections_on_activity_id_and_position",
  ["activityId", "position"],
  {}
)
@Index("index_sections_on_position", ["position"], {})
@Entity("sections", { schema: "portal_development" })
export class Sections {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("int", { name: "activity_id", nullable: true })
  activityId: number | null;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("mediumtext", { name: "description", nullable: true })
  description: string | null;

  @Column("int", { name: "position", nullable: true })
  position: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("tinyint", {
    name: "teacher_only",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  teacherOnly: boolean | null;

  @Column("varchar", {
    name: "publication_status",
    nullable: true,
    length: 255,
  })
  publicationStatus: string | null;
}
