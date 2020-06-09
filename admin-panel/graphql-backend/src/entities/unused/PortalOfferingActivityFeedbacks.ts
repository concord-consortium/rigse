import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("portal_offering_activity_feedbacks", { schema: "portal_development" })
export class PortalOfferingActivityFeedbacks {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("tinyint", {
    name: "enable_text_feedback",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  enableTextFeedback: boolean | null;

  @Column("int", { name: "max_score", nullable: true, default: () => "'10'" })
  maxScore: number | null;

  @Column("varchar", {
    name: "score_type",
    nullable: true,
    length: 255,
    default: () => "'none'",
  })
  scoreType: string | null;

  @Column("int", { name: "activity_id", nullable: true })
  activityId: number | null;

  @Column("int", { name: "portal_offering_id", nullable: true })
  portalOfferingId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("tinyint", { name: "use_rubric", nullable: true, width: 1 })
  useRubric: boolean | null;

  @Column("text", { name: "rubric", nullable: true })
  rubric: string | null;
}
