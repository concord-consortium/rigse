import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("geniverse_cases", { schema: "portal_development" })
export class GeniverseCases {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("int", { name: "order", nullable: true })
  order: number | null;

  @Column("datetime", { name: "created_at", nullable: true })
  createdAt: Date | null;

  @Column("datetime", { name: "updated_at", nullable: true })
  updatedAt: Date | null;

  @Column("varchar", { name: "introImageUrl", nullable: true, length: 255 })
  introImageUrl: string | null;
}
