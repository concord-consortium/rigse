import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_admin_cohorts_on_project_id_and_name", ["projectId", "name"], {
  unique: true,
})
@Index("index_admin_cohorts_on_project_id", ["projectId"], {})
@Entity("admin_cohorts", { schema: "portal_development" })
export class AdminCohorts {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "project_id", nullable: true })
  projectId: number | null;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("tinyint", {
    name: "email_notifications_enabled",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  emailNotificationsEnabled: boolean | null;
}
