import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("images", { schema: "portal_development" })
export class Images {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("mediumtext", { name: "attribution", nullable: true })
  attribution: string | null;

  @Column("varchar", {
    name: "publication_status",
    nullable: true,
    length: 255,
    default: () => "'published'",
  })
  publicationStatus: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("varchar", { name: "image_file_name", nullable: true, length: 255 })
  imageFileName: string | null;

  @Column("varchar", {
    name: "image_content_type",
    nullable: true,
    length: 255,
  })
  imageContentType: string | null;

  @Column("int", { name: "image_file_size", nullable: true })
  imageFileSize: number | null;

  @Column("datetime", { name: "image_updated_at", nullable: true })
  imageUpdatedAt: Date | null;

  @Column("varchar", { name: "license_code", nullable: true, length: 255 })
  licenseCode: string | null;

  @Column("int", { name: "width", nullable: true, default: () => "'0'" })
  width: number | null;

  @Column("int", { name: "height", nullable: true, default: () => "'0'" })
  height: number | null;
}
