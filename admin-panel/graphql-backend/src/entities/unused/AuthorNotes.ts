import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("author_notes", { schema: "portal_development" })
export class AuthorNotes {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("mediumtext", { name: "body", nullable: true })
  body: string | null;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("int", { name: "authored_entity_id", nullable: true })
  authoredEntityId: number | null;

  @Column("varchar", {
    name: "authored_entity_type",
    nullable: true,
    length: 255,
  })
  authoredEntityType: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;
}
