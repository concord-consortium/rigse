import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity("tags", { schema: "portal_development" })
export class Tags {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;
}
