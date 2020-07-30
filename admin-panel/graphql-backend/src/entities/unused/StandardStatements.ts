import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("standard_unique", ["uri", "materialType", "materialId"], {
  unique: true,
})
@Entity("standard_statements", { schema: "portal_development" })
export class StandardStatements {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "uri", nullable: true, length: 255 })
  uri: string | null;

  @Column("varchar", { name: "doc", nullable: true, length: 255 })
  doc: string | null;

  @Column("varchar", {
    name: "statement_notation",
    nullable: true,
    length: 255,
  })
  statementNotation: string | null;

  @Column("varchar", { name: "statement_label", nullable: true, length: 255 })
  statementLabel: string | null;

  @Column("text", { name: "description", nullable: true })
  description: string | null;

  @Column("text", { name: "parents", nullable: true })
  parents: string | null;

  @Column("varchar", { name: "material_type", nullable: true, length: 255 })
  materialType: string | null;

  @Column("int", { name: "material_id", nullable: true })
  materialId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("varchar", { name: "education_level", nullable: true, length: 255 })
  educationLevel: string | null;

  @Column("tinyint", { name: "is_leaf", nullable: true, width: 1 })
  isLeaf: boolean | null;
}
