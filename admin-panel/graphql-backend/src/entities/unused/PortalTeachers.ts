import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_portal_teachers_on_user_id", ["userId"], {})
@Entity("portal_teachers", { schema: "portal_development" })
export class PortalTeachers {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("int", {
    name: "offerings_count",
    nullable: true,
    default: () => "'0'",
  })
  offeringsCount: number | null;

  @Column("int", { name: "left_pane_submenu_item", nullable: true })
  leftPaneSubmenuItem: number | null;
}
