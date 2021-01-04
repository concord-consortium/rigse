import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index(
  "index_users_on_username_and_password_hash",
  ["username", "passwordHash"],
  {}
)
@Entity("geniverse_users", { schema: "portal_development" })
export class GeniverseUsers {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "username", nullable: true, length: 255 })
  username: string | null;

  @Column("varchar", { name: "password_hash", nullable: true, length: 255 })
  passwordHash: string | null;

  @Column("datetime", { name: "created_at", nullable: true })
  createdAt: Date | null;

  @Column("datetime", { name: "updated_at", nullable: true })
  updatedAt: Date | null;

  @Column("int", { name: "group_id", nullable: true })
  groupId: number | null;

  @Column("int", { name: "member_id", nullable: true })
  memberId: number | null;

  @Column("varchar", { name: "first_name", nullable: true, length: 255 })
  firstName: string | null;

  @Column("varchar", { name: "last_name", nullable: true, length: 255 })
  lastName: string | null;

  @Column("mediumtext", { name: "note", nullable: true })
  note: string | null;

  @Column("varchar", { name: "class_name", nullable: true, length: 255 })
  className: string | null;

  @Column("longtext", { name: "metadata", nullable: true })
  metadata: string | null;

  @Column("varchar", { name: "avatar", nullable: true, length: 255 })
  avatar: string | null;
}
