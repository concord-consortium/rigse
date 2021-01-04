import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_standard_documents_on_name", ["name"], { unique: true })
@Entity("standard_documents", { schema: "portal_development" })
export class StandardDocuments {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "uri", nullable: true, length: 255 })
  uri: string | null;

  @Column("varchar", { name: "jurisdiction", nullable: true, length: 255 })
  jurisdiction: string | null;

  @Column("varchar", { name: "title", nullable: true, length: 255 })
  title: string | null;

  @Column("varchar", {
    name: "name",
    nullable: true,
    unique: true,
    length: 255,
  })
  name: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
