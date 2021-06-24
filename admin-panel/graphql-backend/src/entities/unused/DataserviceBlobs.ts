import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_dataservice_blobs_on_checksum", ["checksum"], {})
@Index("index_dataservice_blobs_on_learner_id", ["learnerId"], {})
@Index("pbc_idx", ["periodicBundleContentId"], {})
@Entity("dataservice_blobs", { schema: "portal_development" })
export class DataserviceBlobs {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("mediumblob", { name: "content", nullable: true })
  content: Buffer | null;

  @Column("varchar", { name: "token", nullable: true, length: 255 })
  token: string | null;

  @Column("datetime", { name: "created_at" })
  createdAt: Date;

  @Column("datetime", { name: "updated_at" })
  updatedAt: Date;

  @Column("varchar", { name: "uuid", nullable: true, length: 36 })
  uuid: string | null;

  @Column("varchar", { name: "mimetype", nullable: true, length: 255 })
  mimetype: string | null;

  @Column("varchar", { name: "file_extension", nullable: true, length: 255 })
  fileExtension: string | null;

  @Column("int", { name: "learner_id", nullable: true })
  learnerId: number | null;

  @Column("varchar", { name: "checksum", nullable: true, length: 255 })
  checksum: string | null;
}
