import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("portal_permission_forms", { schema: "portal_development" })
export class PortalPermissionForms {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("varchar", { name: "url", nullable: true, length: 255 })
  url: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("int", { name: "project_id", nullable: true })
  projectId: number | null;
}
