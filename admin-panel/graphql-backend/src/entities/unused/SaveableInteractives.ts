import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("saveable_interactives", { schema: "portal_development" })
export class SaveableInteractives {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "learner_id", nullable: true })
  learnerId: number | null;

  @Column("int", { name: "offering_id", nullable: true })
  offeringId: number | null;

  @Column("int", { name: "response_count", nullable: true })
  responseCount: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("int", { name: "iframe_id", nullable: true })
  iframeId: number | null;
}
