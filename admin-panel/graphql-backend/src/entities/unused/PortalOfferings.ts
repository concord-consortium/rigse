import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_portal_offerings_on_clazz_id", ["clazzId"], {})
@Index("index_portal_offerings_on_runnable_type", ["runnableType"], {})
@Index("index_portal_offerings_on_runnable_id", ["runnableId"], {})
@Entity("portal_offerings", { schema: "portal_development" })
export class PortalOfferings {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("varchar", { name: "status", nullable: true, length: 255 })
  status: string | null;

  @Column("int", { name: "clazz_id", nullable: true })
  clazzId: number | null;

  @Column("int", { name: "runnable_id", nullable: true })
  runnableId: number | null;

  @Column("varchar", { name: "runnable_type", nullable: true, length: 255 })
  runnableType: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("tinyint", {
    name: "active",
    nullable: true,
    width: 1,
    default: () => "'1'",
  })
  active: boolean | null;

  @Column("tinyint", {
    name: "default_offering",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  defaultOffering: boolean | null;

  @Column("int", { name: "position", nullable: true, default: () => "'0'" })
  position: number | null;

  @Column("tinyint", {
    name: "anonymous_report",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  anonymousReport: boolean | null;

  @Column("tinyint", {
    name: "locked",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  locked: boolean | null;
}
