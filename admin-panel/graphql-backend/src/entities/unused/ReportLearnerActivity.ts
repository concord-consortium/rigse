import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_report_learner_activity_on_activity_id", ["activityId"], {})
@Index("index_report_learner_activity_on_learner_id", ["learnerId"], {})
@Entity("report_learner_activity", { schema: "portal_development" })
export class ReportLearnerActivity {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "learner_id", nullable: true })
  learnerId: number | null;

  @Column("int", { name: "activity_id", nullable: true })
  activityId: number | null;

  @Column("float", { name: "complete_percent", nullable: true, precision: 12 })
  completePercent: number | null;
}
