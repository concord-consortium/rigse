import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_admin_notice_user_display_statuses_on_user_id", ["userId"], {})
@Entity("admin_notice_user_display_statuses", { schema: "portal_development" })
export class AdminNoticeUserDisplayStatuses {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("datetime", { name: "last_collapsed_at_time", nullable: true })
  lastCollapsedAtTime: Date | null;

  @Column("tinyint", { name: "collapsed_status", nullable: true, width: 1 })
  collapsedStatus: boolean | null;
}
