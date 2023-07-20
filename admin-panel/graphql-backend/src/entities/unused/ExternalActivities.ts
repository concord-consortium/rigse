import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("featured_public", ["isFeatured", "publicationStatus"], {})
@Index("pub_status", ["publicationStatus"], {})
@Index("index_external_activities_on_save_path", ["savePath"], {})
@Index(
  "index_external_activities_on_template_id_and_template_type",
  ["templateId", "templateType"],
  {}
)
@Index("index_external_activities_on_user_id", ["userId"], {})
@Entity("external_activities", { schema: "portal_development" })
export class ExternalActivities {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("varchar", { name: "uuid", nullable: true, length: 255 })
  uuid: string | null;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("mediumtext", { name: "archived_description", nullable: true })
  archivedDescription: string | null;

  @Column("mediumtext", { name: "url", nullable: true })
  url: string | null;

  @Column("varchar", {
    name: "publication_status",
    nullable: true,
    length: 255,
  })
  publicationStatus: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("int", {
    name: "offerings_count",
    nullable: true,
    default: () => "'0'",
  })
  offeringsCount: number | null;

  @Column("varchar", { name: "save_path", nullable: true, length: 255 })
  savePath: string | null;

  @Column("tinyint", {
    name: "append_learner_id_to_url",
    nullable: true,
    width: 1,
  })
  appendLearnerIdToUrl: boolean | null;

  @Column("tinyint", {
    name: "popup",
    nullable: true,
    width: 1,
    default: () => "'1'",
  })
  popup: boolean | null;

  @Column("tinyint", {
    name: "append_survey_monkey_uid",
    nullable: true,
    width: 1,
  })
  appendSurveyMonkeyUid: boolean | null;

  @Column("int", { name: "template_id", nullable: true })
  templateId: number | null;

  @Column("varchar", { name: "template_type", nullable: true, length: 255 })
  templateType: string | null;

  @Column("tinyint", {
    name: "is_official",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  isOfficial: boolean | null;

  @Column("tinyint", {
    name: "student_report_enabled",
    nullable: true,
    width: 1,
    default: () => "'1'",
  })
  studentReportEnabled: boolean | null;

  @Column("mediumtext", {
    name: "long_description_for_teacher",
    nullable: true,
  })
  longDescriptionForTeacher: string | null;

  @Column("varchar", { name: "teacher_guide_url", nullable: true, length: 255 })
  teacherGuideUrl: string | null;

  @Column("varchar", { name: "thumbnail_url", nullable: true, length: 255 })
  thumbnailUrl: string | null;

  @Column("tinyint", {
    name: "is_featured",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  isFeatured: boolean | null;

  @Column("tinyint", {
    name: "has_pretest",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  hasPretest: boolean | null;

  @Column("mediumtext", { name: "short_description", nullable: true })
  shortDescription: string | null;

  @Column("tinyint", {
    name: "allow_collaboration",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  allowCollaboration: boolean | null;

  @Column("varchar", { name: "author_email", nullable: true, length: 255 })
  authorEmail: string | null;

  @Column("tinyint", { name: "is_locked", nullable: true, width: 1 })
  isLocked: boolean | null;

  @Column("tinyint", {
    name: "logging",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  logging: boolean | null;

  @Column("tinyint", {
    name: "is_assessment_item",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  isAssessmentItem: boolean | null;

  @Column("text", { name: "author_url", nullable: true })
  authorUrl: string | null;

  @Column("text", { name: "print_url", nullable: true })
  printUrl: string | null;

  @Column("tinyint", {
    name: "is_archived",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  isArchived: boolean | null;

  @Column("datetime", { name: "archive_date", nullable: true })
  archiveDate: Date | null;

  @Column("varchar", { name: "credits", nullable: true, length: 255 })
  credits: string | null;

  @Column("varchar", { name: "license_code", nullable: true, length: 255 })
  licenseCode: string | null;

  @Column("tinyint", {
    name: "enable_sharing",
    nullable: true,
    width: 1,
    default: () => "'1'",
  })
  enableSharing: boolean | null;

  @Column("tinyint", { name: "append_auth_token", nullable: true, width: 1 })
  appendAuthToken: boolean | null;

  @Column("varchar", {
    name: "material_type",
    nullable: true,
    length: 255,
    default: () => "'Activity'",
  })
  materialType: string | null;

  @Column("varchar", { name: "rubric_url", nullable: true, length: 255 })
  rubricUrl: string | null;

  @Column("varchar", { name: "rubric_doc_url", nullable: true, length: 255 })
  rubricDocUrl: string | null;

  @Column("tinyint", {
    name: "saves_student_data",
    nullable: true,
    width: 1,
    default: () => "'1'",
  })
  savesStudentData: boolean | null;

  @Column("text", { name: "long_description", nullable: true })
  longDescription: string | null;

  @Column("text", { name: "keywords", nullable: true })
  keywords: string | null;

  @Column("int", { name: "tool_id", nullable: true })
  toolId: number | null;

  @Column("tinyint", {
    name: "has_teacher_edition",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  hasTeacherEdition: boolean | null;
}
