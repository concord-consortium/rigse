import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("tools", { schema: "portal_development" })
export class Tools {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("varchar", { name: "source_type", nullable: true, length: 255 })
  sourceType: string | null;

  @Column("text", { name: "tool_id", nullable: true })
  toolId: string | null;
}
