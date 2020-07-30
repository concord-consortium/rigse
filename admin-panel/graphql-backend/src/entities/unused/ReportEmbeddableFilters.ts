import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_report_embeddable_filters_on_offering_id", ["offeringId"], {})
@Entity("report_embeddable_filters", { schema: "portal_development" })
export class ReportEmbeddableFilters {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "offering_id", nullable: true })
  offeringId: number | null;

  @Column("mediumtext", { name: "embeddables", nullable: true })
  embeddables: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("tinyint", { name: "ignore", nullable: true, width: 1 })
  ignore: boolean | null;
}
