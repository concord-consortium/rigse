import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("embeddable_iframes", { schema: "portal_development" })
export class EmbeddableIframes {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("varchar", { name: "description", nullable: true, length: 255 })
  description: string | null;

  @Column("int", { name: "width", nullable: true })
  width: number | null;

  @Column("int", { name: "height", nullable: true })
  height: number | null;

  @Column("varchar", { name: "url", nullable: true, length: 255 })
  url: string | null;

  @Column("varchar", { name: "external_id", nullable: true, length: 255 })
  externalId: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("tinyint", {
    name: "display_in_iframe",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  displayInIframe: boolean | null;

  @Column("tinyint", {
    name: "is_required",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  isRequired: boolean | null;

  @Column("tinyint", {
    name: "show_in_featured_question_report",
    nullable: true,
    width: 1,
    default: () => "'1'",
  })
  showInFeaturedQuestionReport: boolean | null;
}
