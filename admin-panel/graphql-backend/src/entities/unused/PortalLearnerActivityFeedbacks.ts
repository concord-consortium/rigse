import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index(
  "index_portal_learner_activity_feedbacks_on_activity_feedback_id",
  ["activityFeedbackId"],
  {}
)
@Index(
  "index_portal_learner_activity_feedbacks_on_portal_learner_id",
  ["portalLearnerId"],
  {}
)
@Entity("portal_learner_activity_feedbacks", { schema: "portal_development" })
export class PortalLearnerActivityFeedbacks {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("text", { name: "text_feedback", nullable: true })
  textFeedback: string | null;

  @Column("int", { name: "score", nullable: true, default: () => "'0'" })
  score: number | null;

  @Column("tinyint", {
    name: "has_been_reviewed",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  hasBeenReviewed: boolean | null;

  @Column("int", { name: "portal_learner_id", nullable: true })
  portalLearnerId: number | null;

  @Column("int", { name: "activity_feedback_id", nullable: true })
  activityFeedbackId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("text", { name: "rubric_feedback", nullable: true })
  rubricFeedback: string | null;
}
