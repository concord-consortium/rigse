import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("geniverse_articles", { schema: "portal_development" })
export class GeniverseArticles {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "group", nullable: true })
  group: number | null;

  @Column("int", { name: "activity_id", nullable: true })
  activityId: number | null;

  @Column("mediumtext", { name: "text", nullable: true })
  text: string | null;

  @Column("int", { name: "time", nullable: true })
  time: number | null;

  @Column("tinyint", { name: "submitted", nullable: true, width: 1 })
  submitted: boolean | null;

  @Column("mediumtext", { name: "teacherComment", nullable: true })
  teacherComment: string | null;

  @Column("tinyint", { name: "accepted", nullable: true, width: 1 })
  accepted: boolean | null;

  @Column("datetime", { name: "created_at", nullable: true })
  createdAt: Date | null;

  @Column("datetime", { name: "updated_at", nullable: true })
  updatedAt: Date | null;
}
