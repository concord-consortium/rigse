import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("embeddable_multiple_choices", { schema: "portal_development" })
export class EmbeddableMultipleChoices {
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

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("tinyint", {
    name: "enable_rationale",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  enableRationale: boolean | null;

  @Column("mediumtext", { name: "rationale_prompt", nullable: true })
  rationalePrompt: string | null;

  @Column("tinyint", {
    name: "allow_multiple_selection",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  allowMultipleSelection: boolean | null;

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
