import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("admin_settings", { schema: "portal_development" })
export class AdminSettings {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("mediumtext", { name: "description", nullable: true })
  description: string | null;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("mediumtext", { name: "home_page_content", nullable: true })
  homePageContent: string | null;

  @Column("tinyint", {
    name: "use_student_security_questions",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  useStudentSecurityQuestions: boolean | null;

  @Column("tinyint", { name: "allow_default_class", nullable: true, width: 1 })
  allowDefaultClass: boolean | null;

  @Column("tinyint", {
    name: "enable_grade_levels",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  enableGradeLevels: boolean | null;

  @Column("tinyint", {
    name: "use_bitmap_snapshots",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  useBitmapSnapshots: boolean | null;

  @Column("tinyint", {
    name: "teachers_can_author",
    nullable: true,
    width: 1,
    default: () => "'1'",
  })
  teachersCanAuthor: boolean | null;

  @Column("tinyint", {
    name: "enable_member_registration",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  enableMemberRegistration: boolean | null;

  @Column("tinyint", {
    name: "allow_adhoc_schools",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  allowAdhocSchools: boolean | null;

  @Column("tinyint", {
    name: "require_user_consent",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  requireUserConsent: boolean | null;

  @Column("tinyint", { name: "active", nullable: true, width: 1 })
  active: boolean | null;

  @Column("varchar", { name: "external_url", nullable: true, length: 255 })
  externalUrl: string | null;

  @Column("mediumtext", { name: "custom_help_page_html", nullable: true })
  customHelpPageHtml: string | null;

  @Column("varchar", { name: "help_type", nullable: true, length: 255 })
  helpType: string | null;

  @Column("tinyint", {
    name: "include_external_activities",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  includeExternalActivities: boolean | null;

  @Column("mediumtext", { name: "enabled_bookmark_types", nullable: true })
  enabledBookmarkTypes: string | null;

  @Column("int", {
    name: "pub_interval",
    nullable: true,
    default: () => "'10'",
  })
  pubInterval: number | null;

  @Column("tinyint", {
    name: "anonymous_can_browse_materials",
    nullable: true,
    width: 1,
    default: () => "'1'",
  })
  anonymousCanBrowseMaterials: boolean | null;

  @Column("tinyint", {
    name: "show_collections_menu",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  showCollectionsMenu: boolean | null;

  @Column("tinyint", {
    name: "auto_set_teachers_as_authors",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  autoSetTeachersAsAuthors: boolean | null;

  @Column("int", { name: "default_cohort_id", nullable: true })
  defaultCohortId: number | null;

  @Column("tinyint", {
    name: "wrap_home_page_content",
    nullable: true,
    width: 1,
    default: () => "'1'",
  })
  wrapHomePageContent: boolean | null;

  @Column("varchar", {
    name: "custom_search_path",
    nullable: true,
    length: 255,
    default: () => "'/search'",
  })
  customSearchPath: string | null;

  @Column("varchar", {
    name: "teacher_home_path",
    nullable: true,
    length: 255,
    default: () => "'/getting_started'",
  })
  teacherHomePath: string | null;

  @Column("mediumtext", { name: "about_page_content", nullable: true })
  aboutPageContent: string | null;
}
