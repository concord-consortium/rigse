import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index(
  "index_saveable_external_link_urls_on_external_link_id",
  ["externalLinkId"],
  {}
)
@Entity("saveable_external_link_urls", { schema: "portal_development" })
export class SaveableExternalLinkUrls {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "external_link_id", nullable: true })
  externalLinkId: number | null;

  @Column("int", { name: "position", nullable: true })
  position: number | null;

  @Column("text", { name: "url", nullable: true })
  url: string | null;

  @Column("tinyint", { name: "is_final", nullable: true, width: 1 })
  isFinal: boolean | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("text", { name: "feedback", nullable: true })
  feedback: string | null;

  @Column("tinyint", {
    name: "has_been_reviewed",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  hasBeenReviewed: boolean | null;

  @Column("int", { name: "score", nullable: true })
  score: number | null;
}
