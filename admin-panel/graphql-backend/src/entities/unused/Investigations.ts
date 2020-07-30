import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("featured_public", ["isFeatured", "publicationStatus"], {})
@Index("pub_status", ["publicationStatus"], {})
@Entity("investigations", { schema: "portal_development" })
export class Investigations {
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

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("tinyint", {
    name: "teacher_only",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  teacherOnly: boolean | null;

  @Column("varchar", {
    name: "publication_status",
    nullable: true,
    length: 255,
  })
  publicationStatus: string | null;

  @Column("int", {
    name: "offerings_count",
    nullable: true,
    default: () => "'0'",
  })
  offeringsCount: number | null;

  @Column("tinyint", {
    name: "student_report_enabled",
    nullable: true,
    width: 1,
    default: () => "'1'",
  })
  studentReportEnabled: boolean | null;

  @Column("tinyint", {
    name: "allow_activity_assignment",
    nullable: true,
    width: 1,
    default: () => "'1'",
  })
  allowActivityAssignment: boolean | null;

  @Column("tinyint", {
    name: "show_score",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  showScore: boolean | null;

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

  @Column("mediumtext", { name: "abstract", nullable: true })
  abstract: string | null;

  @Column("varchar", { name: "author_email", nullable: true, length: 255 })
  authorEmail: string | null;

  @Column("tinyint", {
    name: "is_assessment_item",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  isAssessmentItem: boolean | null;
}
