import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index(
  "index_dataservice_bucket_log_items_on_bucket_logger_id",
  ["bucketLoggerId"],
  {}
)
@Entity("dataservice_bucket_log_items", { schema: "portal_development" })
export class DataserviceBucketLogItems {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("mediumtext", { name: "content", nullable: true })
  content: string | null;

  @Column("int", { name: "bucket_logger_id", nullable: true })
  bucketLoggerId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
