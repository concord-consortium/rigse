import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("admin_project_links", { schema: "portal_development" })
export class AdminProjectLinks {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "project_id", nullable: true })
  projectId: number | null;

  @Column("mediumtext", { name: "name", nullable: true })
  name: string | null;

  @Column("mediumtext", { name: "href", nullable: true })
  href: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("varchar", { name: "link_id", nullable: true, length: 255 })
  linkId: string | null;

  @Column("tinyint", { name: "pop_out", nullable: true, width: 1 })
  popOut: boolean | null;

  @Column("int", { name: "position", nullable: true, default: () => "'5'" })
  position: number | null;
}
