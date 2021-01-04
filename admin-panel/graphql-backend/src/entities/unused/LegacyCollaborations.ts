import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("legacy_collaborations", { schema: "portal_development" })
export class LegacyCollaborations {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "bundle_content_id", nullable: true })
  bundleContentId: number | null;

  @Column("int", { name: "student_id", nullable: true })
  studentId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
