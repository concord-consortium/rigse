import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("admin_proj_mat_mat_idx", ["materialId", "materialType"], {})
@Index(
  "admin_proj_mat_proj_mat_idx",
  ["projectId", "materialId", "materialType"],
  {}
)
@Index("admin_proj_mat_proj_idx", ["projectId"], {})
@Entity("admin_project_materials", { schema: "portal_development" })
export class AdminProjectMaterials {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "project_id", nullable: true })
  projectId: number | null;

  @Column("int", { name: "material_id", nullable: true })
  materialId: number | null;

  @Column("varchar", { name: "material_type", nullable: true, length: 255 })
  materialType: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
