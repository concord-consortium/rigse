import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("favorite_unique", ["userId", "favoritableId", "favoritableType"], {
  unique: true,
})
@Index("index_favorites_on_favoritable_id", ["favoritableId"], {})
@Index("index_favorites_on_favoritable_type", ["favoritableType"], {})
@Entity("favorites", { schema: "portal_development" })
export class Favorites {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "user_id", nullable: true })
  userId: number | null;

  @Column("int", { name: "favoritable_id", nullable: true })
  favoritableId: number | null;

  @Column("varchar", { name: "favoritable_type", nullable: true, length: 255 })
  favoritableType: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;
}
