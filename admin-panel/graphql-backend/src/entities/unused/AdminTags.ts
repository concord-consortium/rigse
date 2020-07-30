import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("admin_tags", { schema: "portal_development" })
export class AdminTags {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "scope", nullable: true, length: 255 })
  scope: string | null;

  @Column("varchar", { name: "tag", nullable: true, length: 255 })
  tag: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
