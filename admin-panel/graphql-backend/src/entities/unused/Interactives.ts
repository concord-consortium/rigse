import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("interactives", { schema: "portal_development" })
export class Interactives {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("mediumtext", { name: "description", nullable: true })
  description: string | null;

  @Column("varchar", { name: "url", nullable: true, length: 255 })
  url: string | null;

  @Column("int", { name: "width", nullable: true })
  width: number | null;

  @Column("int", { name: "height", nullable: true })
  height: number | null;

  @Column("float", { name: "scale", nullable: true, precision: 12 })
  scale: number | null;

  @Column("varchar", { name: "image_url", nullable: true, length: 255 })
  imageUrl: string | null;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("varchar", { name: "credits", nullable: true, length: 255 })
  credits: string | null;

  @Column("varchar", {
    name: "publication_status",
    nullable: true,
    length: 255,
  })
  publicationStatus: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("tinyint", {
    name: "full_window",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  fullWindow: boolean | null;

  @Column("tinyint", {
    name: "no_snapshots",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  noSnapshots: boolean | null;

  @Column("tinyint", {
    name: "save_interactive_state",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  saveInteractiveState: boolean | null;

  @Column("varchar", { name: "license_code", nullable: true, length: 255 })
  licenseCode: string | null;

  @Column("int", { name: "external_activity_id", nullable: true })
  externalActivityId: number | null;
}
