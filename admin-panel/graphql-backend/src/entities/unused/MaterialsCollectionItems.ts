import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("material_idx", ["materialId", "materialType", "position"], {})
@Index("materials_collection_idx", ["materialsCollectionId", "position"], {})
@Entity("materials_collection_items", { schema: "portal_development" })
export class MaterialsCollectionItems {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "materials_collection_id", nullable: true })
  materialsCollectionId: number | null;

  @Column("varchar", { name: "material_type", nullable: true, length: 255 })
  materialType: string | null;

  @Column("int", { name: "material_id", nullable: true })
  materialId: number | null;

  @Column("int", { name: "position", nullable: true })
  position: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
