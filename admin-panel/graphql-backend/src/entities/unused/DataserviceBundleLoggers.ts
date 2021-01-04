import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index(
  "index_dataservice_bundle_loggers_on_in_progress_bundle_id",
  ["inProgressBundleId"],
  {}
)
@Entity("dataservice_bundle_loggers", { schema: "portal_development" })
export class DataserviceBundleLoggers {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("int", { name: "in_progress_bundle_id", nullable: true })
  inProgressBundleId: number | null;
}
