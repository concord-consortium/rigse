import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_admin_site_notice_roles_on_notice_id", ["noticeId"], {})
@Index("index_admin_site_notice_roles_on_role_id", ["roleId"], {})
@Entity("admin_site_notice_roles", { schema: "portal_development" })
export class AdminSiteNoticeRoles {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "notice_id", nullable: true })
  noticeId: number | null;

  @Column("int", { name: "role_id", nullable: true })
  roleId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
