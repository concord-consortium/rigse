import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("portal_grades", { schema: "portal_development" })
export class PortalGrades {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("varchar", { name: "description", nullable: true, length: 255 })
  description: string | null;

  @Column("int", { name: "position", nullable: true })
  position: number | null;

  @Column("varchar", { name: "uuid", nullable: true, length: 255 })
  uuid: string | null;

  @Column("tinyint", {
    name: "active",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  active: boolean | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
