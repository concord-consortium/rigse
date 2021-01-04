import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_admin_cohort_items_on_item_id", ["itemId"], {})
@Index("index_admin_cohort_items_on_item_type", ["itemType"], {})
@Index("index_admin_cohort_items_on_admin_cohort_id", ["adminCohortId"], {})
@Entity("admin_cohort_items", { schema: "portal_development" })
export class AdminCohortItems {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "admin_cohort_id", nullable: true })
  adminCohortId: number | null;

  @Column("int", { name: "item_id", nullable: true })
  itemId: number | null;

  @Column("varchar", { name: "item_type", nullable: true, length: 255 })
  itemType: string | null;
}
