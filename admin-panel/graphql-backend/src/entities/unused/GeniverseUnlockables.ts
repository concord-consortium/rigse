import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("geniverse_unlockables", { schema: "portal_development" })
export class GeniverseUnlockables {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "title", nullable: true, length: 255 })
  title: string | null;

  @Column("mediumtext", { name: "content", nullable: true })
  content: string | null;

  @Column("varchar", { name: "trigger", nullable: true, length: 255 })
  trigger: string | null;

  @Column("datetime", { name: "created_at", nullable: true })
  createdAt: Date | null;

  @Column("datetime", { name: "updated_at", nullable: true })
  updatedAt: Date | null;

  @Column("tinyint", {
    name: "open_automatically",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  openAutomatically: boolean | null;
}
