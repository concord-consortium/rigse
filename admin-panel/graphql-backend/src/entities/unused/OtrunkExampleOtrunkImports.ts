import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_otrunk_example_otrunk_imports_on_fq_classname", ["fqClassname"], {
  unique: true,
})
@Entity("otrunk_example_otrunk_imports", { schema: "portal_development" })
export class OtrunkExampleOtrunkImports {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "uuid", nullable: true, length: 255 })
  uuid: string | null;

  @Column("varchar", { name: "classname", nullable: true, length: 255 })
  classname: string | null;

  @Column("varchar", {
    name: "fq_classname",
    nullable: true,
    unique: true,
    length: 255,
  })
  fqClassname: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
