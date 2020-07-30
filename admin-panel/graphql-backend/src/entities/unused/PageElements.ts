import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index(
  "index_page_elements_on_embeddable_id_and_embeddable_type",
  ["embeddableId", "embeddableType"],
  {}
)
@Index("index_page_elements_on_embeddable_id", ["embeddableId"], {})
@Index("index_page_elements_on_page_id", ["pageId"], {})
@Index("index_page_elements_on_position", ["position"], {})
@Entity("page_elements", { schema: "portal_development" })
export class PageElements {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "page_id", nullable: true })
  pageId: number | null;

  @Column("int", { name: "embeddable_id", nullable: true })
  embeddableId: number | null;

  @Column("varchar", { name: "embeddable_type", nullable: true, length: 255 })
  embeddableType: string | null;

  @Column("int", { name: "position", nullable: true })
  position: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;
}
