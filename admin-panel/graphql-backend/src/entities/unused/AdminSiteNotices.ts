import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_admin_site_notices_on_created_by", ["createdBy"], {})
@Index("index_admin_site_notices_on_updated_by", ["updatedBy"], {})
@Entity("admin_site_notices", { schema: "portal_development" })
export class AdminSiteNotices {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("mediumtext", { name: "notice_html", nullable: true })
  noticeHtml: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("int", { name: "created_by", nullable: true })
  createdBy: number | null;

  @Column("int", { name: "updated_by", nullable: true })
  updatedBy: number | null;
}
