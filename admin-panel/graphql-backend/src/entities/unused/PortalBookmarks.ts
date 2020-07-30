import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_bookmarks_on_clazz_id", ["clazzId"], {})
@Index("index_portal_bookmarks_on_id_and_type", ["id", "type"], {})
@Index("index_portal_bookmarks_on_user_id", ["userId"], {})
@Entity("portal_bookmarks", { schema: "portal_development" })
export class PortalBookmarks {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("varchar", { name: "type", nullable: true, length: 255 })
  type: string | null;

  @Column("varchar", { name: "url", nullable: true, length: 255 })
  url: string | null;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("int", { name: "position", nullable: true })
  position: number | null;

  @Column("int", { name: "clazz_id", nullable: true })
  clazzId: number | null;

  @Column("tinyint", { name: "is_visible", width: 1, default: () => "'1'" })
  isVisible: boolean;
}
