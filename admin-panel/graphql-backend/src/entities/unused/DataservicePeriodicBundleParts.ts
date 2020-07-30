import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("parts_key_index", ["key"], {})
@Index("bundle_logger_index", ["periodicBundleLoggerId"], {})
@Entity("dataservice_periodic_bundle_parts", { schema: "portal_development" })
export class DataservicePeriodicBundleParts {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "periodic_bundle_logger_id", nullable: true })
  periodicBundleLoggerId: number | null;

  @Column("tinyint", {
    name: "delta",
    nullable: true,
    width: 1,
    default: () => "'1'",
  })
  delta: boolean | null;

  @Column("varchar", { name: "key", nullable: true, length: 255 })
  key: string | null;

  @Column("longtext", { name: "value", nullable: true })
  value: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
