import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_portal_collaborations_on_offering_id", ["offeringId"], {})
@Index("index_portal_collaborations_on_owner_id", ["ownerId"], {})
@Entity("portal_collaborations", { schema: "portal_development" })
export class PortalCollaborations {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "owner_id", nullable: true })
  ownerId: number | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("int", { name: "offering_id", nullable: true })
  offeringId: number | null;
}
