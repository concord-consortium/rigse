import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("saveable_sparks_measuring_resistance_reports", {
  schema: "portal_development",
})
export class SaveableSparksMeasuringResistanceReports {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "measuring_resistance_id", nullable: true })
  measuringResistanceId: number | null;

  @Column("int", { name: "position", nullable: true })
  position: number | null;

  @Column("mediumtext", { name: "content", nullable: true })
  content: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
