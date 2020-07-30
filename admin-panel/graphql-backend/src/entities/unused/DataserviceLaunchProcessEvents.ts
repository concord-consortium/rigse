import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index(
  "index_dataservice_launch_process_events_on_bundle_content_id",
  ["bundleContentId"],
  {}
)
@Entity("dataservice_launch_process_events", { schema: "portal_development" })
export class DataserviceLaunchProcessEvents {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "event_type", nullable: true, length: 255 })
  eventType: string | null;

  @Column("mediumtext", { name: "event_details", nullable: true })
  eventDetails: string | null;

  @Column("int", { name: "bundle_content_id", nullable: true })
  bundleContentId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
