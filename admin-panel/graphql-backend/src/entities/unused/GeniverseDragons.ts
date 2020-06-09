import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_dragons_on_activity_id", ["activityId"], {})
@Index("breed_record_index", ["breederId", "breedTime", "id"], {})
@Index("father_index", ["fatherId"], {})
@Index("index_dragons_on_id", ["id"], {})
@Index("mother_index", ["motherId"], {})
@Index("index_dragons_on_user_id", ["userId"], {})
@Entity("geniverse_dragons", { schema: "portal_development" })
export class GeniverseDragons {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("varchar", { name: "name", nullable: true, length: 255 })
  name: string | null;

  @Column("int", { name: "sex", nullable: true })
  sex: number | null;

  @Column("varchar", { name: "alleles", nullable: true, length: 255 })
  alleles: string | null;

  @Column("varchar", { name: "imageURL", nullable: true, length: 255 })
  imageUrl: string | null;

  @Column("int", { name: "mother_id", nullable: true })
  motherId: number | null;

  @Column("int", { name: "father_id", nullable: true })
  fatherId: number | null;

  @Column("tinyint", { name: "bred", nullable: true, width: 1 })
  bred: boolean | null;

  @Column("datetime", { name: "created_at", nullable: true })
  createdAt: Date | null;

  @Column("datetime", { name: "updated_at", nullable: true })
  updatedAt: Date | null;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("int", { name: "stableOrder", nullable: true })
  stableOrder: number | null;

  @Column("tinyint", {
    name: "isEgg",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  isEgg: boolean | null;

  @Column("tinyint", {
    name: "isInMarketplace",
    nullable: true,
    width: 1,
    default: () => "'1'",
  })
  isInMarketplace: boolean | null;

  @Column("int", { name: "activity_id", nullable: true })
  activityId: number | null;

  @Column("int", { name: "breeder_id", nullable: true })
  breederId: number | null;

  @Column("varchar", { name: "breedTime", nullable: true, length: 16 })
  breedTime: string | null;

  @Column("tinyint", {
    name: "isMatchDragon",
    nullable: true,
    width: 1,
    default: () => "'0'",
  })
  isMatchDragon: boolean | null;
}
