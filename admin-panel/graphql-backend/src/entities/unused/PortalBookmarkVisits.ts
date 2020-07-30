import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("portal_bookmark_visits", { schema: "portal_development" })
export class PortalBookmarkVisits {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("int", { name: "bookmark_id", nullable: true })
  bookmarkId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
