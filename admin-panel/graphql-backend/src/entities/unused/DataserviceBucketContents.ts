import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index(
  "index_dataservice_bucket_contents_on_bucket_logger_id",
  ["bucketLoggerId"],
  {}
)
@Entity("dataservice_bucket_contents", { schema: "portal_development" })
export class DataserviceBucketContents {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "bucket_logger_id", nullable: true })
  bucketLoggerId: number | null;

  @Column("mediumtext", { name: "body", nullable: true })
  body: string | null;

  @Column("tinyint", { name: "processed", nullable: true, width: 1 })
  processed: boolean | null;

  @Column("tinyint", { name: "empty", nullable: true, width: 1 })
  empty: boolean | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
