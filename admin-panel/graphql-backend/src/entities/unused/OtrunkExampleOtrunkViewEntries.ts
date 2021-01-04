import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index(
  "index_otrunk_example_otrunk_view_entries_on_fq_classname",
  ["fqClassname"],
  { unique: true }
)
@Entity("otrunk_example_otrunk_view_entries", { schema: "portal_development" })
export class OtrunkExampleOtrunkViewEntries {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "uuid", nullable: true, length: 255 })
  uuid: string | null;

  @Column("int", { name: "otrunk_import_id", nullable: true })
  otrunkImportId: number | null;

  @Column("varchar", { name: "classname", nullable: true, length: 255 })
  classname: string | null;

  @Column("varchar", {
    name: "fq_classname",
    nullable: true,
    unique: true,
    length: 255,
  })
  fqClassname: string | null;

  @Column("tinyint", { name: "standard_view", nullable: true, width: 1 })
  standardView: boolean | null;

  @Column("tinyint", { name: "standard_edit_view", nullable: true, width: 1 })
  standardEditView: boolean | null;

  @Column("tinyint", { name: "edit_view", nullable: true, width: 1 })
  editView: boolean | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
