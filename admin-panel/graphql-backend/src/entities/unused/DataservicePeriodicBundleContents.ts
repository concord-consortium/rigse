import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("bundle_logger_index", ["periodicBundleLoggerId"], {})
@Entity("dataservice_periodic_bundle_contents", {
  schema: "portal_development",
})
export class DataservicePeriodicBundleContents {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "periodic_bundle_logger_id", nullable: true })
  periodicBundleLoggerId: number | null;

  @Column("longtext", { name: "body", nullable: true })
  body: string | null;

  @Column("tinyint", { name: "processed", nullable: true, width: 1 })
  processed: boolean | null;

  @Column("tinyint", { name: "valid_xml", nullable: true, width: 1 })
  validXml: boolean | null;

  @Column("tinyint", { name: "empty", nullable: true, width: 1 })
  empty: boolean | null;

  @Column("varchar", { name: "uuid", nullable: true, length: 255 })
  uuid: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("tinyint", {
    name: "parts_extracted",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  partsExtracted: boolean | null;
}
