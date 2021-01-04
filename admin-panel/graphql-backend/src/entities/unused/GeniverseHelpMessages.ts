import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("geniverse_help_messages", { schema: "portal_development" })
export class GeniverseHelpMessages {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "page_name", nullable: true, length: 255 })
  pageName: string | null;

  @Column("mediumtext", { name: "message", nullable: true })
  message: string | null;

  @Column("datetime", { name: "created_at", nullable: true })
  createdAt: Date | null;

  @Column("datetime", { name: "updated_at", nullable: true })
  updatedAt: Date | null;
}
