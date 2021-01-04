import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index(
  "index_dataservice_bundle_contents_on_bundle_logger_id",
  ["bundleLoggerId"],
  {}
)
@Index(
  "index_dataservice_bundle_contents_on_collaboration_id",
  ["collaborationId"],
  {}
)
@Entity("dataservice_bundle_contents", { schema: "portal_development" })
export class DataserviceBundleContents {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "bundle_logger_id", nullable: true })
  bundleLoggerId: number | null;

  @Column("int", { name: "position", nullable: true })
  position: number | null;

  @Column("longtext", { name: "body", nullable: true })
  body: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("longtext", { name: "otml", nullable: true })
  otml: string | null;

  @Column("tinyint", { name: "processed", nullable: true, width: 1 })
  processed: boolean | null;

  @Column("tinyint", {
    name: "valid_xml",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  validXml: boolean | null;

  @Column("tinyint", {
    name: "empty",
    nullable: true,
    width: 1,
    default: () => "'1'",
  })
  empty: boolean | null;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("mediumtext", { name: "original_body", nullable: true })
  originalBody: string | null;

  @Column("float", { name: "upload_time", nullable: true, precision: 12 })
  uploadTime: number | null;

  @Column("int", { name: "collaboration_id", nullable: true })
  collaborationId: number | null;
}
