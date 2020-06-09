import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("installer_reports", { schema: "portal_development" })
export class InstallerReports {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("mediumtext", { name: "body", nullable: true })
  body: string | null;

  @Column("varchar", { name: "remote_ip", nullable: true, length: 255 })
  remoteIp: string | null;

  @Column("tinyint", { name: "success", nullable: true, width: 1 })
  success: boolean | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("int", { name: "jnlp_session_id", nullable: true })
  jnlpSessionId: number | null;
}
