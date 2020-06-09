import { Column, PrimaryColumn, Entity, Index } from "typeorm";

@Index(
  "activity_reports_activity_index",
  ["externalActivityId", "externalReportId"],
  {}
)
@Index("activity_reports_index", ["externalReportId"], {})
@Entity("external_activity_reports", { schema: "portal_development" })
export class ExternalActivityReports {
  @PrimaryColumn("int", { name: "external_activity_id", nullable: false })
  externalActivityId: number | null;

  @Column("int", { name: "external_report_id", nullable: true })
  externalReportId: number | null;
}
