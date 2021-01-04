import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_admin_site_notice_users_on_notice_id", ["noticeId"], {})
@Index("index_admin_site_notice_users_on_user_id", ["userId"], {})
@Entity("admin_site_notice_users", { schema: "portal_development" })
export class AdminSiteNoticeUsers {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "notice_id", nullable: true })
  noticeId: number | null;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("tinyint", { name: "notice_dismissed", nullable: true, width: 1 })
  noticeDismissed: boolean | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
