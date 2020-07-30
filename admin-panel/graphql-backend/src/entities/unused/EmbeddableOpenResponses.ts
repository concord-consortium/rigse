import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("embeddable_open_responses", { schema: "portal_development" })
export class EmbeddableOpenResponses {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("mediumtext", { name: "description", nullable: true })
  description: string | null;

  @Column("mediumtext", { name: "prompt", nullable: true })
  prompt: string | null;

  @Column("varchar", { name: "default_response", nullable: true, length: 255 })
  defaultResponse: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("int", { name: "rows", nullable: true, default: () => "'5'" })
  rows: number | null;

  @Column("int", { name: "columns", nullable: true, default: () => "'32'" })
  columns: number | null;

  @Column("int", { name: "font_size", nullable: true, default: () => "'12'" })
  fontSize: number | null;

  @Column("varchar", { name: "external_id", nullable: true, length: 255 })
  externalId: string | null;

  @Column("tinyint", { name: "is_required", width: 1, default: () => "'0'" })
  isRequired: boolean;

  @Column("tinyint", {
    name: "show_in_featured_question_report",
    nullable: true,
    width: 1,
    default: () => "'1'",
  })
  showInFeaturedQuestionReport: boolean | null;
}
