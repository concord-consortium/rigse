import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_taggings_on_tag_id", ["tagId"], {})
@Index(
  "index_taggings_on_taggable_id_and_taggable_type_and_context",
  ["taggableId", "taggableType", "context"],
  {}
)
@Entity("taggings", { schema: "portal_development" })
export class Taggings {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "tag_id", nullable: true })
  tagId: number | null;

  @Column("int", { name: "taggable_id", nullable: true })
  taggableId: number | null;

  @Column("int", { name: "tagger_id", nullable: true })
  taggerId: number | null;

  @Column("varchar", { name: "tagger_type", nullable: true, length: 255 })
  taggerType: string | null;

  @Column("varchar", { name: "taggable_type", nullable: true, length: 255 })
  taggableType: string | null;

  @Column("varchar", { name: "context", nullable: true, length: 255 })
  context: string | null;

  @Column("datetime", { name: "created_at", nullable: true })
  createdAt: Date | null;
}
