import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_external_reports_on_client_id", ["clientId"], {})
@Entity("external_reports", { schema: "portal_development" })
export class ExternalReports {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "url", nullable: true, length: 255 })
  url: string | null;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("varchar", { name: "launch_text", nullable: true, length: 255 })
  launchText: string | null;

  @Column("int", { name: "client_id", nullable: true })
  clientId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("varchar", {
    name: "report_type",
    nullable: true,
    length: 255,
    default: () => "'offering'",
  })
  reportType: string | null;

  @Column("tinyint", {
    name: "allowed_for_students",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  allowedForStudents: boolean | null;

  @Column("varchar", {
    name: "default_report_for_source_type",
    nullable: true,
    length: 255,
  })
  defaultReportForSourceType: string | null;

  @Column("tinyint", {
    name: "individual_student_reportable",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  individualStudentReportable: boolean | null;

  @Column("tinyint", {
    name: "individual_activity_reportable",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  individualActivityReportable: boolean | null;

  @Column("text", { name: "move_students_api_url", nullable: true })
  moveStudentsApiUrl: string | null;

  @Column("varchar", {
    name: "move_students_api_token",
    nullable: true,
    length: 255,
  })
  moveStudentsApiToken: string | null;
}
