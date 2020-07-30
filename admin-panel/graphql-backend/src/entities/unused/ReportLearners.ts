import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_report_learners_on_class_id", ["classId"], {})
@Index("index_report_learners_on_last_run", ["lastRun"], {})
@Index("index_report_learners_on_learner_id", ["learnerId"], {})
@Index("index_report_learners_on_offering_id", ["offeringId"], {})
@Index(
  "index_report_learners_on_runnable_id_and_runnable_type",
  ["runnableId", "runnableType"],
  {}
)
@Index("index_report_learners_on_runnable_id", ["runnableId"], {})
@Index("index_report_learners_on_school_id", ["schoolId"], {})
@Index("index_report_learners_on_student_id", ["studentId"], {})
@Entity("report_learners", { schema: "portal_development" })
export class ReportLearners {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "learner_id", nullable: true })
  learnerId: number | null;

  @Column("int", { name: "student_id", nullable: true })
  studentId: number | null;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("int", { name: "offering_id", nullable: true })
  offeringId: number | null;

  @Column("int", { name: "class_id", nullable: true })
  classId: number | null;

  @Column("datetime", { name: "last_run", nullable: true })
  lastRun: Date | null;

  @Column("datetime", { name: "last_report", nullable: true })
  lastReport: Date | null;

  @Column("varchar", { name: "offering_name", nullable: true, length: 255 })
  offeringName: string | null;

  @Column("varchar", { name: "teachers_name", nullable: true, length: 255 })
  teachersName: string | null;

  @Column("varchar", { name: "student_name", nullable: true, length: 255 })
  studentName: string | null;

  @Column("varchar", { name: "username", nullable: true, length: 255 })
  username: string | null;

  @Column("varchar", { name: "school_name", nullable: true, length: 255 })
  schoolName: string | null;

  @Column("varchar", { name: "class_name", nullable: true, length: 255 })
  className: string | null;

  @Column("int", { name: "runnable_id", nullable: true })
  runnableId: number | null;

  @Column("varchar", { name: "runnable_name", nullable: true, length: 255 })
  runnableName: string | null;

  @Column("int", { name: "school_id", nullable: true })
  schoolId: number | null;

  @Column("int", { name: "num_answerables", nullable: true })
  numAnswerables: number | null;

  @Column("int", { name: "num_answered", nullable: true })
  numAnswered: number | null;

  @Column("int", { name: "num_correct", nullable: true })
  numCorrect: number | null;

  @Column("longtext", { name: "answers", nullable: true })
  answers: string | null;

  @Column("varchar", { name: "runnable_type", nullable: true, length: 255 })
  runnableType: string | null;

  @Column("float", { name: "complete_percent", nullable: true, precision: 12 })
  completePercent: number | null;

  @Column("mediumtext", { name: "permission_forms", nullable: true })
  permissionForms: string | null;

  @Column("int", { name: "num_submitted", nullable: true })
  numSubmitted: number | null;

  @Column("varchar", { name: "teachers_district", nullable: true, length: 255 })
  teachersDistrict: string | null;

  @Column("varchar", { name: "teachers_state", nullable: true, length: 255 })
  teachersState: string | null;

  @Column("varchar", { name: "teachers_email", nullable: true, length: 255 })
  teachersEmail: string | null;

  @Column("varchar", {
    name: "permission_forms_id",
    nullable: true,
    length: 255,
  })
  permissionFormsId: string | null;

  @Column("varchar", { name: "teachers_id", nullable: true, length: 255 })
  teachersId: string | null;

  @Column("text", { name: "teachers_map", nullable: true })
  teachersMap: string | null;

  @Column("text", { name: "permission_forms_map", nullable: true })
  permissionFormsMap: string | null;
}
