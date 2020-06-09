import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_materials_collections_on_project_id", ["projectId"], {})
@Entity("materials_collections", { schema: "portal_development" })
export class MaterialsCollections {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("mediumtext", { name: "description", nullable: true })
  description: string | null;

  @Column("int", { name: "project_id", nullable: true })
  projectId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
