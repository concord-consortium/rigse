import { Column, Entity, Index, PrimaryGeneratedColumn } from "typeorm";

@Index("index_portal_nces06_schools_on_NCESSCH", ["ncessch"], {})
@Index("index_portal_nces06_schools_on_SCHNAM", ["schnam"], {})
@Index("index_portal_nces06_schools_on_SEASCH", ["seasch"], {})
@Index("index_portal_nces06_schools_on_STID", ["stid"], {})
@Index(
  "index_portal_nces06_schools_on_nces_district_id",
  ["ncesDistrictId"],
  {}
)
@Entity("portal_nces06_schools", { schema: "portal_development" })
export class PortalNces06Schools {
  @PrimaryGeneratedColumn({ type: "int", name: "id" })
  id: number;

  @Column("int", { name: "nces_district_id", nullable: true })
  ncesDistrictId: number | null;

  @Column("varchar", { name: "NCESSCH", nullable: true, length: 12 })
  ncessch: string | null;

  @Column("varchar", { name: "FIPST", nullable: true, length: 2 })
  fipst: string | null;

  @Column("varchar", { name: "LEAID", nullable: true, length: 7 })
  leaid: string | null;

  @Column("varchar", { name: "SCHNO", nullable: true, length: 5 })
  schno: string | null;

  @Column("varchar", { name: "STID", nullable: true, length: 14 })
  stid: string | null;

  @Column("varchar", { name: "SEASCH", nullable: true, length: 20 })
  seasch: string | null;

  @Column("varchar", { name: "LEANM", nullable: true, length: 60 })
  leanm: string | null;

  @Column("varchar", { name: "SCHNAM", nullable: true, length: 50 })
  schnam: string | null;

  @Column("varchar", { name: "PHONE", nullable: true, length: 10 })
  phone: string | null;

  @Column("varchar", { name: "MSTREE", nullable: true, length: 30 })
  mstree: string | null;

  @Column("varchar", { name: "MCITY", nullable: true, length: 30 })
  mcity: string | null;

  @Column("varchar", { name: "MSTATE", nullable: true, length: 2 })
  mstate: string | null;

  @Column("varchar", { name: "MZIP", nullable: true, length: 5 })
  mzip: string | null;

  @Column("varchar", { name: "MZIP4", nullable: true, length: 4 })
  mzip4: string | null;

  @Column("varchar", { name: "LSTREE", nullable: true, length: 30 })
  lstree: string | null;

  @Column("varchar", { name: "LCITY", nullable: true, length: 30 })
  lcity: string | null;

  @Column("varchar", { name: "LSTATE", nullable: true, length: 2 })
  lstate: string | null;

  @Column("varchar", { name: "LZIP", nullable: true, length: 5 })
  lzip: string | null;

  @Column("varchar", { name: "LZIP4", nullable: true, length: 4 })
  lzip4: string | null;

  @Column("varchar", { name: "KIND", nullable: true, length: 1 })
  kind: string | null;

  @Column("varchar", { name: "STATUS", nullable: true, length: 1 })
  status: string | null;

  @Column("varchar", { name: "ULOCAL", nullable: true, length: 2 })
  ulocal: string | null;

  @Column("float", { name: "LATCOD", nullable: true, precision: 12 })
  latcod: number | null;

  @Column("float", { name: "LONCOD", nullable: true, precision: 12 })
  loncod: number | null;

  @Column("varchar", { name: "CDCODE", nullable: true, length: 4 })
  cdcode: string | null;

  @Column("varchar", { name: "CONUM", nullable: true, length: 5 })
  conum: string | null;

  @Column("varchar", { name: "CONAME", nullable: true, length: 30 })
  coname: string | null;

  @Column("float", { name: "FTE", nullable: true, precision: 12 })
  fte: number | null;

  @Column("varchar", { name: "GSLO", nullable: true, length: 2 })
  gslo: string | null;

  @Column("varchar", { name: "GSHI", nullable: true, length: 2 })
  gshi: string | null;

  @Column("varchar", { name: "LEVEL", nullable: true, length: 1 })
  level: string | null;

  @Column("varchar", { name: "TITLEI", nullable: true, length: 1 })
  titlei: string | null;

  @Column("varchar", { name: "STITLI", nullable: true, length: 1 })
  stitli: string | null;

  @Column("varchar", { name: "MAGNET", nullable: true, length: 1 })
  magnet: string | null;

  @Column("varchar", { name: "CHARTR", nullable: true, length: 1 })
  chartr: string | null;

  @Column("varchar", { name: "SHARED", nullable: true, length: 1 })
  shared: string | null;

  @Column("int", { name: "FRELCH", nullable: true })
  frelch: number | null;

  @Column("int", { name: "REDLCH", nullable: true })
  redlch: number | null;

  @Column("int", { name: "TOTFRL", nullable: true })
  totfrl: number | null;

  @Column("int", { name: "MIGRNT", nullable: true })
  migrnt: number | null;

  @Column("int", { name: "PK", nullable: true })
  pk: number | null;

  @Column("int", { name: "AMPKM", nullable: true })
  ampkm: number | null;

  @Column("int", { name: "AMPKF", nullable: true })
  ampkf: number | null;

  @Column("int", { name: "AMPKU", nullable: true })
  ampku: number | null;

  @Column("int", { name: "ASPKM", nullable: true })
  aspkm: number | null;

  @Column("int", { name: "ASPKF", nullable: true })
  aspkf: number | null;

  @Column("int", { name: "ASPKU", nullable: true })
  aspku: number | null;

  @Column("int", { name: "HIPKM", nullable: true })
  hipkm: number | null;

  @Column("int", { name: "HIPKF", nullable: true })
  hipkf: number | null;

  @Column("int", { name: "HIPKU", nullable: true })
  hipku: number | null;

  @Column("int", { name: "BLPKM", nullable: true })
  blpkm: number | null;

  @Column("int", { name: "BLPKF", nullable: true })
  blpkf: number | null;

  @Column("int", { name: "BLPKU", nullable: true })
  blpku: number | null;

  @Column("int", { name: "WHPKM", nullable: true })
  whpkm: number | null;

  @Column("int", { name: "WHPKF", nullable: true })
  whpkf: number | null;

  @Column("int", { name: "WHPKU", nullable: true })
  whpku: number | null;

  @Column("int", { name: "KG", nullable: true })
  kg: number | null;

  @Column("int", { name: "AMKGM", nullable: true })
  amkgm: number | null;

  @Column("int", { name: "AMKGF", nullable: true })
  amkgf: number | null;

  @Column("int", { name: "AMKGU", nullable: true })
  amkgu: number | null;

  @Column("int", { name: "ASKGM", nullable: true })
  askgm: number | null;

  @Column("int", { name: "ASKGF", nullable: true })
  askgf: number | null;

  @Column("int", { name: "ASKGU", nullable: true })
  askgu: number | null;

  @Column("int", { name: "HIKGM", nullable: true })
  hikgm: number | null;

  @Column("int", { name: "HIKGF", nullable: true })
  hikgf: number | null;

  @Column("int", { name: "HIKGU", nullable: true })
  hikgu: number | null;

  @Column("int", { name: "BLKGM", nullable: true })
  blkgm: number | null;

  @Column("int", { name: "BLKGF", nullable: true })
  blkgf: number | null;

  @Column("int", { name: "BLKGU", nullable: true })
  blkgu: number | null;

  @Column("int", { name: "WHKGM", nullable: true })
  whkgm: number | null;

  @Column("int", { name: "WHKGF", nullable: true })
  whkgf: number | null;

  @Column("int", { name: "WHKGU", nullable: true })
  whkgu: number | null;

  @Column("int", { name: "G01", nullable: true })
  g01: number | null;

  @Column("int", { name: "AM01M", nullable: true })
  am01M: number | null;

  @Column("int", { name: "AM01F", nullable: true })
  am01F: number | null;

  @Column("int", { name: "AM01U", nullable: true })
  am01U: number | null;

  @Column("int", { name: "AS01M", nullable: true })
  as01M: number | null;

  @Column("int", { name: "AS01F", nullable: true })
  as01F: number | null;

  @Column("int", { name: "AS01U", nullable: true })
  as01U: number | null;

  @Column("int", { name: "HI01M", nullable: true })
  hi01M: number | null;

  @Column("int", { name: "HI01F", nullable: true })
  hi01F: number | null;

  @Column("int", { name: "HI01U", nullable: true })
  hi01U: number | null;

  @Column("int", { name: "BL01M", nullable: true })
  bl01M: number | null;

  @Column("int", { name: "BL01F", nullable: true })
  bl01F: number | null;

  @Column("int", { name: "BL01U", nullable: true })
  bl01U: number | null;

  @Column("int", { name: "WH01M", nullable: true })
  wh01M: number | null;

  @Column("int", { name: "WH01F", nullable: true })
  wh01F: number | null;

  @Column("int", { name: "WH01U", nullable: true })
  wh01U: number | null;

  @Column("int", { name: "G02", nullable: true })
  g02: number | null;

  @Column("int", { name: "AM02M", nullable: true })
  am02M: number | null;

  @Column("int", { name: "AM02F", nullable: true })
  am02F: number | null;

  @Column("int", { name: "AM02U", nullable: true })
  am02U: number | null;

  @Column("int", { name: "AS02M", nullable: true })
  as02M: number | null;

  @Column("int", { name: "AS02F", nullable: true })
  as02F: number | null;

  @Column("int", { name: "AS02U", nullable: true })
  as02U: number | null;

  @Column("int", { name: "HI02M", nullable: true })
  hi02M: number | null;

  @Column("int", { name: "HI02F", nullable: true })
  hi02F: number | null;

  @Column("int", { name: "HI02U", nullable: true })
  hi02U: number | null;

  @Column("int", { name: "BL02M", nullable: true })
  bl02M: number | null;

  @Column("int", { name: "BL02F", nullable: true })
  bl02F: number | null;

  @Column("int", { name: "BL02U", nullable: true })
  bl02U: number | null;

  @Column("int", { name: "WH02M", nullable: true })
  wh02M: number | null;

  @Column("int", { name: "WH02F", nullable: true })
  wh02F: number | null;

  @Column("int", { name: "WH02U", nullable: true })
  wh02U: number | null;

  @Column("int", { name: "G03", nullable: true })
  g03: number | null;

  @Column("int", { name: "AM03M", nullable: true })
  am03M: number | null;

  @Column("int", { name: "AM03F", nullable: true })
  am03F: number | null;

  @Column("int", { name: "AM03U", nullable: true })
  am03U: number | null;

  @Column("int", { name: "AS03M", nullable: true })
  as03M: number | null;

  @Column("int", { name: "AS03F", nullable: true })
  as03F: number | null;

  @Column("int", { name: "AS03U", nullable: true })
  as03U: number | null;

  @Column("int", { name: "HI03M", nullable: true })
  hi03M: number | null;

  @Column("int", { name: "HI03F", nullable: true })
  hi03F: number | null;

  @Column("int", { name: "HI03U", nullable: true })
  hi03U: number | null;

  @Column("int", { name: "BL03M", nullable: true })
  bl03M: number | null;

  @Column("int", { name: "BL03F", nullable: true })
  bl03F: number | null;

  @Column("int", { name: "BL03U", nullable: true })
  bl03U: number | null;

  @Column("int", { name: "WH03M", nullable: true })
  wh03M: number | null;

  @Column("int", { name: "WH03F", nullable: true })
  wh03F: number | null;

  @Column("int", { name: "WH03U", nullable: true })
  wh03U: number | null;

  @Column("int", { name: "G04", nullable: true })
  g04: number | null;

  @Column("int", { name: "AM04M", nullable: true })
  am04M: number | null;

  @Column("int", { name: "AM04F", nullable: true })
  am04F: number | null;

  @Column("int", { name: "AM04U", nullable: true })
  am04U: number | null;

  @Column("int", { name: "AS04M", nullable: true })
  as04M: number | null;

  @Column("int", { name: "AS04F", nullable: true })
  as04F: number | null;

  @Column("int", { name: "AS04U", nullable: true })
  as04U: number | null;

  @Column("int", { name: "HI04M", nullable: true })
  hi04M: number | null;

  @Column("int", { name: "HI04F", nullable: true })
  hi04F: number | null;

  @Column("int", { name: "HI04U", nullable: true })
  hi04U: number | null;

  @Column("int", { name: "BL04M", nullable: true })
  bl04M: number | null;

  @Column("int", { name: "BL04F", nullable: true })
  bl04F: number | null;

  @Column("int", { name: "BL04U", nullable: true })
  bl04U: number | null;

  @Column("int", { name: "WH04M", nullable: true })
  wh04M: number | null;

  @Column("int", { name: "WH04F", nullable: true })
  wh04F: number | null;

  @Column("int", { name: "WH04U", nullable: true })
  wh04U: number | null;

  @Column("int", { name: "G05", nullable: true })
  g05: number | null;

  @Column("int", { name: "AM05M", nullable: true })
  am05M: number | null;

  @Column("int", { name: "AM05F", nullable: true })
  am05F: number | null;

  @Column("int", { name: "AM05U", nullable: true })
  am05U: number | null;

  @Column("int", { name: "AS05M", nullable: true })
  as05M: number | null;

  @Column("int", { name: "AS05F", nullable: true })
  as05F: number | null;

  @Column("int", { name: "AS05U", nullable: true })
  as05U: number | null;

  @Column("int", { name: "HI05M", nullable: true })
  hi05M: number | null;

  @Column("int", { name: "HI05F", nullable: true })
  hi05F: number | null;

  @Column("int", { name: "HI05U", nullable: true })
  hi05U: number | null;

  @Column("int", { name: "BL05M", nullable: true })
  bl05M: number | null;

  @Column("int", { name: "BL05F", nullable: true })
  bl05F: number | null;

  @Column("int", { name: "BL05U", nullable: true })
  bl05U: number | null;

  @Column("int", { name: "WH05M", nullable: true })
  wh05M: number | null;

  @Column("int", { name: "WH05F", nullable: true })
  wh05F: number | null;

  @Column("int", { name: "WH05U", nullable: true })
  wh05U: number | null;

  @Column("int", { name: "G06", nullable: true })
  g06: number | null;

  @Column("int", { name: "AM06M", nullable: true })
  am06M: number | null;

  @Column("int", { name: "AM06F", nullable: true })
  am06F: number | null;

  @Column("int", { name: "AM06U", nullable: true })
  am06U: number | null;

  @Column("int", { name: "AS06M", nullable: true })
  as06M: number | null;

  @Column("int", { name: "AS06F", nullable: true })
  as06F: number | null;

  @Column("int", { name: "AS06U", nullable: true })
  as06U: number | null;

  @Column("int", { name: "HI06M", nullable: true })
  hi06M: number | null;

  @Column("int", { name: "HI06F", nullable: true })
  hi06F: number | null;

  @Column("int", { name: "HI06U", nullable: true })
  hi06U: number | null;

  @Column("int", { name: "BL06M", nullable: true })
  bl06M: number | null;

  @Column("int", { name: "BL06F", nullable: true })
  bl06F: number | null;

  @Column("int", { name: "BL06U", nullable: true })
  bl06U: number | null;

  @Column("int", { name: "WH06M", nullable: true })
  wh06M: number | null;

  @Column("int", { name: "WH06F", nullable: true })
  wh06F: number | null;

  @Column("int", { name: "WH06U", nullable: true })
  wh06U: number | null;

  @Column("int", { name: "G07", nullable: true })
  g07: number | null;

  @Column("int", { name: "AM07M", nullable: true })
  am07M: number | null;

  @Column("int", { name: "AM07F", nullable: true })
  am07F: number | null;

  @Column("int", { name: "AM07U", nullable: true })
  am07U: number | null;

  @Column("int", { name: "AS07M", nullable: true })
  as07M: number | null;

  @Column("int", { name: "AS07F", nullable: true })
  as07F: number | null;

  @Column("int", { name: "AS07U", nullable: true })
  as07U: number | null;

  @Column("int", { name: "HI07M", nullable: true })
  hi07M: number | null;

  @Column("int", { name: "HI07F", nullable: true })
  hi07F: number | null;

  @Column("int", { name: "HI07U", nullable: true })
  hi07U: number | null;

  @Column("int", { name: "BL07M", nullable: true })
  bl07M: number | null;

  @Column("int", { name: "BL07F", nullable: true })
  bl07F: number | null;

  @Column("int", { name: "BL07U", nullable: true })
  bl07U: number | null;

  @Column("int", { name: "WH07M", nullable: true })
  wh07M: number | null;

  @Column("int", { name: "WH07F", nullable: true })
  wh07F: number | null;

  @Column("int", { name: "WH07U", nullable: true })
  wh07U: number | null;

  @Column("int", { name: "G08", nullable: true })
  g08: number | null;

  @Column("int", { name: "AM08M", nullable: true })
  am08M: number | null;

  @Column("int", { name: "AM08F", nullable: true })
  am08F: number | null;

  @Column("int", { name: "AM08U", nullable: true })
  am08U: number | null;

  @Column("int", { name: "AS08M", nullable: true })
  as08M: number | null;

  @Column("int", { name: "AS08F", nullable: true })
  as08F: number | null;

  @Column("int", { name: "AS08U", nullable: true })
  as08U: number | null;

  @Column("int", { name: "HI08M", nullable: true })
  hi08M: number | null;

  @Column("int", { name: "HI08F", nullable: true })
  hi08F: number | null;

  @Column("int", { name: "HI08U", nullable: true })
  hi08U: number | null;

  @Column("int", { name: "BL08M", nullable: true })
  bl08M: number | null;

  @Column("int", { name: "BL08F", nullable: true })
  bl08F: number | null;

  @Column("int", { name: "BL08U", nullable: true })
  bl08U: number | null;

  @Column("int", { name: "WH08M", nullable: true })
  wh08M: number | null;

  @Column("int", { name: "WH08F", nullable: true })
  wh08F: number | null;

  @Column("int", { name: "WH08U", nullable: true })
  wh08U: number | null;

  @Column("int", { name: "G09", nullable: true })
  g09: number | null;

  @Column("int", { name: "AM09M", nullable: true })
  am09M: number | null;

  @Column("int", { name: "AM09F", nullable: true })
  am09F: number | null;

  @Column("int", { name: "AM09U", nullable: true })
  am09U: number | null;

  @Column("int", { name: "AS09M", nullable: true })
  as09M: number | null;

  @Column("int", { name: "AS09F", nullable: true })
  as09F: number | null;

  @Column("int", { name: "AS09U", nullable: true })
  as09U: number | null;

  @Column("int", { name: "HI09M", nullable: true })
  hi09M: number | null;

  @Column("int", { name: "HI09F", nullable: true })
  hi09F: number | null;

  @Column("int", { name: "HI09U", nullable: true })
  hi09U: number | null;

  @Column("int", { name: "BL09M", nullable: true })
  bl09M: number | null;

  @Column("int", { name: "BL09F", nullable: true })
  bl09F: number | null;

  @Column("int", { name: "BL09U", nullable: true })
  bl09U: number | null;

  @Column("int", { name: "WH09M", nullable: true })
  wh09M: number | null;

  @Column("int", { name: "WH09F", nullable: true })
  wh09F: number | null;

  @Column("int", { name: "WH09U", nullable: true })
  wh09U: number | null;

  @Column("int", { name: "G10", nullable: true })
  g10: number | null;

  @Column("int", { name: "AM10M", nullable: true })
  am10M: number | null;

  @Column("int", { name: "AM10F", nullable: true })
  am10F: number | null;

  @Column("int", { name: "AM10U", nullable: true })
  am10U: number | null;

  @Column("int", { name: "AS10M", nullable: true })
  as10M: number | null;

  @Column("int", { name: "AS10F", nullable: true })
  as10F: number | null;

  @Column("int", { name: "AS10U", nullable: true })
  as10U: number | null;

  @Column("int", { name: "HI10M", nullable: true })
  hi10M: number | null;

  @Column("int", { name: "HI10F", nullable: true })
  hi10F: number | null;

  @Column("int", { name: "HI10U", nullable: true })
  hi10U: number | null;

  @Column("int", { name: "BL10M", nullable: true })
  bl10M: number | null;

  @Column("int", { name: "BL10F", nullable: true })
  bl10F: number | null;

  @Column("int", { name: "BL10U", nullable: true })
  bl10U: number | null;

  @Column("int", { name: "WH10M", nullable: true })
  wh10M: number | null;

  @Column("int", { name: "WH10F", nullable: true })
  wh10F: number | null;

  @Column("int", { name: "WH10U", nullable: true })
  wh10U: number | null;

  @Column("int", { name: "G11", nullable: true })
  g11: number | null;

  @Column("int", { name: "AM11M", nullable: true })
  am11M: number | null;

  @Column("int", { name: "AM11F", nullable: true })
  am11F: number | null;

  @Column("int", { name: "AM11U", nullable: true })
  am11U: number | null;

  @Column("int", { name: "AS11M", nullable: true })
  as11M: number | null;

  @Column("int", { name: "AS11F", nullable: true })
  as11F: number | null;

  @Column("int", { name: "AS11U", nullable: true })
  as11U: number | null;

  @Column("int", { name: "HI11M", nullable: true })
  hi11M: number | null;

  @Column("int", { name: "HI11F", nullable: true })
  hi11F: number | null;

  @Column("int", { name: "HI11U", nullable: true })
  hi11U: number | null;

  @Column("int", { name: "BL11M", nullable: true })
  bl11M: number | null;

  @Column("int", { name: "BL11F", nullable: true })
  bl11F: number | null;

  @Column("int", { name: "BL11U", nullable: true })
  bl11U: number | null;

  @Column("int", { name: "WH11M", nullable: true })
  wh11M: number | null;

  @Column("int", { name: "WH11F", nullable: true })
  wh11F: number | null;

  @Column("int", { name: "WH11U", nullable: true })
  wh11U: number | null;

  @Column("int", { name: "G12", nullable: true })
  g12: number | null;

  @Column("int", { name: "AM12M", nullable: true })
  am12M: number | null;

  @Column("int", { name: "AM12F", nullable: true })
  am12F: number | null;

  @Column("int", { name: "AM12U", nullable: true })
  am12U: number | null;

  @Column("int", { name: "AS12M", nullable: true })
  as12M: number | null;

  @Column("int", { name: "AS12F", nullable: true })
  as12F: number | null;

  @Column("int", { name: "AS12U", nullable: true })
  as12U: number | null;

  @Column("int", { name: "HI12M", nullable: true })
  hi12M: number | null;

  @Column("int", { name: "HI12F", nullable: true })
  hi12F: number | null;

  @Column("int", { name: "HI12U", nullable: true })
  hi12U: number | null;

  @Column("int", { name: "BL12M", nullable: true })
  bl12M: number | null;

  @Column("int", { name: "BL12F", nullable: true })
  bl12F: number | null;

  @Column("int", { name: "BL12U", nullable: true })
  bl12U: number | null;

  @Column("int", { name: "WH12M", nullable: true })
  wh12M: number | null;

  @Column("int", { name: "WH12F", nullable: true })
  wh12F: number | null;

  @Column("int", { name: "WH12U", nullable: true })
  wh12U: number | null;

  @Column("int", { name: "UG", nullable: true })
  ug: number | null;

  @Column("int", { name: "AMUGM", nullable: true })
  amugm: number | null;

  @Column("int", { name: "AMUGF", nullable: true })
  amugf: number | null;

  @Column("int", { name: "AMUGU", nullable: true })
  amugu: number | null;

  @Column("int", { name: "ASUGM", nullable: true })
  asugm: number | null;

  @Column("int", { name: "ASUGF", nullable: true })
  asugf: number | null;

  @Column("int", { name: "ASUGU", nullable: true })
  asugu: number | null;

  @Column("int", { name: "HIUGM", nullable: true })
  hiugm: number | null;

  @Column("int", { name: "HIUGF", nullable: true })
  hiugf: number | null;

  @Column("int", { name: "HIUGU", nullable: true })
  hiugu: number | null;

  @Column("int", { name: "BLUGM", nullable: true })
  blugm: number | null;

  @Column("int", { name: "BLUGF", nullable: true })
  blugf: number | null;

  @Column("int", { name: "BLUGU", nullable: true })
  blugu: number | null;

  @Column("int", { name: "WHUGM", nullable: true })
  whugm: number | null;

  @Column("int", { name: "WHUGF", nullable: true })
  whugf: number | null;

  @Column("int", { name: "WHUGU", nullable: true })
  whugu: number | null;

  @Column("int", { name: "MEMBER", nullable: true })
  member: number | null;

  @Column("int", { name: "AM", nullable: true })
  am: number | null;

  @Column("int", { name: "AMALM", nullable: true })
  amalm: number | null;

  @Column("int", { name: "AMALF", nullable: true })
  amalf: number | null;

  @Column("int", { name: "AMALU", nullable: true })
  amalu: number | null;

  @Column("int", { name: "ASIAN", nullable: true })
  asian: number | null;

  @Column("int", { name: "ASALM", nullable: true })
  asalm: number | null;

  @Column("int", { name: "ASALF", nullable: true })
  asalf: number | null;

  @Column("int", { name: "ASALU", nullable: true })
  asalu: number | null;

  @Column("int", { name: "HISP", nullable: true })
  hisp: number | null;

  @Column("int", { name: "HIALM", nullable: true })
  hialm: number | null;

  @Column("int", { name: "HIALF", nullable: true })
  hialf: number | null;

  @Column("int", { name: "HIALU", nullable: true })
  hialu: number | null;

  @Column("int", { name: "BLACK", nullable: true })
  black: number | null;

  @Column("int", { name: "BLALM", nullable: true })
  blalm: number | null;

  @Column("int", { name: "BLALF", nullable: true })
  blalf: number | null;

  @Column("int", { name: "BLALU", nullable: true })
  blalu: number | null;

  @Column("int", { name: "WHITE", nullable: true })
  white: number | null;

  @Column("int", { name: "WHALM", nullable: true })
  whalm: number | null;

  @Column("int", { name: "WHALF", nullable: true })
  whalf: number | null;

  @Column("int", { name: "WHALU", nullable: true })
  whalu: number | null;

  @Column("int", { name: "TOTETH", nullable: true })
  toteth: number | null;

  @Column("float", { name: "PUPTCH", nullable: true, precision: 12 })
  puptch: number | null;

  @Column("int", { name: "TOTGRD", nullable: true })
  totgrd: number | null;

  @Column("varchar", { name: "IFTE", nullable: true, length: 1 })
  ifte: string | null;

  @Column("varchar", { name: "IGSLO", nullable: true, length: 1 })
  igslo: string | null;

  @Column("varchar", { name: "IGSHI", nullable: true, length: 1 })
  igshi: string | null;

  @Column("varchar", { name: "ITITLI", nullable: true, length: 1 })
  ititli: string | null;

  @Column("varchar", { name: "ISTITL", nullable: true, length: 1 })
  istitl: string | null;

  @Column("varchar", { name: "IMAGNE", nullable: true, length: 1 })
  imagne: string | null;

  @Column("varchar", { name: "ICHART", nullable: true, length: 1 })
  ichart: string | null;

  @Column("varchar", { name: "ISHARE", nullable: true, length: 1 })
  ishare: string | null;

  @Column("varchar", { name: "IFRELC", nullable: true, length: 1 })
  ifrelc: string | null;

  @Column("varchar", { name: "IREDLC", nullable: true, length: 1 })
  iredlc: string | null;

  @Column("varchar", { name: "ITOTFR", nullable: true, length: 1 })
  itotfr: string | null;

  @Column("varchar", { name: "IMIGRN", nullable: true, length: 1 })
  imigrn: string | null;

  @Column("varchar", { name: "IPK", nullable: true, length: 1 })
  ipk: string | null;

  @Column("varchar", { name: "IAMPKM", nullable: true, length: 1 })
  iampkm: string | null;

  @Column("varchar", { name: "IAMPKF", nullable: true, length: 1 })
  iampkf: string | null;

  @Column("varchar", { name: "IAMPKU", nullable: true, length: 1 })
  iampku: string | null;

  @Column("varchar", { name: "IASPKM", nullable: true, length: 1 })
  iaspkm: string | null;

  @Column("varchar", { name: "IASPKF", nullable: true, length: 1 })
  iaspkf: string | null;

  @Column("varchar", { name: "IASPKU", nullable: true, length: 1 })
  iaspku: string | null;

  @Column("varchar", { name: "IHIPKM", nullable: true, length: 1 })
  ihipkm: string | null;

  @Column("varchar", { name: "IHIPKF", nullable: true, length: 1 })
  ihipkf: string | null;

  @Column("varchar", { name: "IHIPKU", nullable: true, length: 1 })
  ihipku: string | null;

  @Column("varchar", { name: "IBLPKM", nullable: true, length: 1 })
  iblpkm: string | null;

  @Column("varchar", { name: "IBLPKF", nullable: true, length: 1 })
  iblpkf: string | null;

  @Column("varchar", { name: "IBLPKU", nullable: true, length: 1 })
  iblpku: string | null;

  @Column("varchar", { name: "IWHPKM", nullable: true, length: 1 })
  iwhpkm: string | null;

  @Column("varchar", { name: "IWHPKF", nullable: true, length: 1 })
  iwhpkf: string | null;

  @Column("varchar", { name: "IWHPKU", nullable: true, length: 1 })
  iwhpku: string | null;

  @Column("varchar", { name: "IKG", nullable: true, length: 1 })
  ikg: string | null;

  @Column("varchar", { name: "IAMKGM", nullable: true, length: 1 })
  iamkgm: string | null;

  @Column("varchar", { name: "IAMKGF", nullable: true, length: 1 })
  iamkgf: string | null;

  @Column("varchar", { name: "IAMKGU", nullable: true, length: 1 })
  iamkgu: string | null;

  @Column("varchar", { name: "IASKGM", nullable: true, length: 1 })
  iaskgm: string | null;

  @Column("varchar", { name: "IASKGF", nullable: true, length: 1 })
  iaskgf: string | null;

  @Column("varchar", { name: "IASKGU", nullable: true, length: 1 })
  iaskgu: string | null;

  @Column("varchar", { name: "IHIKGM", nullable: true, length: 1 })
  ihikgm: string | null;

  @Column("varchar", { name: "IHIKGF", nullable: true, length: 1 })
  ihikgf: string | null;

  @Column("varchar", { name: "IHIKGU", nullable: true, length: 1 })
  ihikgu: string | null;

  @Column("varchar", { name: "IBLKGM", nullable: true, length: 1 })
  iblkgm: string | null;

  @Column("varchar", { name: "IBLKGF", nullable: true, length: 1 })
  iblkgf: string | null;

  @Column("varchar", { name: "IBLKGU", nullable: true, length: 1 })
  iblkgu: string | null;

  @Column("varchar", { name: "IWHKGM", nullable: true, length: 1 })
  iwhkgm: string | null;

  @Column("varchar", { name: "IWHKGF", nullable: true, length: 1 })
  iwhkgf: string | null;

  @Column("varchar", { name: "IWHKGU", nullable: true, length: 1 })
  iwhkgu: string | null;

  @Column("varchar", { name: "IG01", nullable: true, length: 1 })
  ig01: string | null;

  @Column("varchar", { name: "IAM01M", nullable: true, length: 1 })
  iam01M: string | null;

  @Column("varchar", { name: "IAM01F", nullable: true, length: 1 })
  iam01F: string | null;

  @Column("varchar", { name: "IAM01U", nullable: true, length: 1 })
  iam01U: string | null;

  @Column("varchar", { name: "IAS01M", nullable: true, length: 1 })
  ias01M: string | null;

  @Column("varchar", { name: "IAS01F", nullable: true, length: 1 })
  ias01F: string | null;

  @Column("varchar", { name: "IAS01U", nullable: true, length: 1 })
  ias01U: string | null;

  @Column("varchar", { name: "IHI01M", nullable: true, length: 1 })
  ihi01M: string | null;

  @Column("varchar", { name: "IHI01F", nullable: true, length: 1 })
  ihi01F: string | null;

  @Column("varchar", { name: "IHI01U", nullable: true, length: 1 })
  ihi01U: string | null;

  @Column("varchar", { name: "IBL01M", nullable: true, length: 1 })
  ibl01M: string | null;

  @Column("varchar", { name: "IBL01F", nullable: true, length: 1 })
  ibl01F: string | null;

  @Column("varchar", { name: "IBL01U", nullable: true, length: 1 })
  ibl01U: string | null;

  @Column("varchar", { name: "IWH01M", nullable: true, length: 1 })
  iwh01M: string | null;

  @Column("varchar", { name: "IWH01F", nullable: true, length: 1 })
  iwh01F: string | null;

  @Column("varchar", { name: "IWH01U", nullable: true, length: 1 })
  iwh01U: string | null;

  @Column("varchar", { name: "IG02", nullable: true, length: 1 })
  ig02: string | null;

  @Column("varchar", { name: "IAM02M", nullable: true, length: 1 })
  iam02M: string | null;

  @Column("varchar", { name: "IAM02F", nullable: true, length: 1 })
  iam02F: string | null;

  @Column("varchar", { name: "IAM02U", nullable: true, length: 1 })
  iam02U: string | null;

  @Column("varchar", { name: "IAS02M", nullable: true, length: 1 })
  ias02M: string | null;

  @Column("varchar", { name: "IAS02F", nullable: true, length: 1 })
  ias02F: string | null;

  @Column("varchar", { name: "IAS02U", nullable: true, length: 1 })
  ias02U: string | null;

  @Column("varchar", { name: "IHI02M", nullable: true, length: 1 })
  ihi02M: string | null;

  @Column("varchar", { name: "IHI02F", nullable: true, length: 1 })
  ihi02F: string | null;

  @Column("varchar", { name: "IHI02U", nullable: true, length: 1 })
  ihi02U: string | null;

  @Column("varchar", { name: "IBL02M", nullable: true, length: 1 })
  ibl02M: string | null;

  @Column("varchar", { name: "IBL02F", nullable: true, length: 1 })
  ibl02F: string | null;

  @Column("varchar", { name: "IBL02U", nullable: true, length: 1 })
  ibl02U: string | null;

  @Column("varchar", { name: "IWH02M", nullable: true, length: 1 })
  iwh02M: string | null;

  @Column("varchar", { name: "IWH02F", nullable: true, length: 1 })
  iwh02F: string | null;

  @Column("varchar", { name: "IWH02U", nullable: true, length: 1 })
  iwh02U: string | null;

  @Column("varchar", { name: "IG03", nullable: true, length: 1 })
  ig03: string | null;

  @Column("varchar", { name: "IAM03M", nullable: true, length: 1 })
  iam03M: string | null;

  @Column("varchar", { name: "IAM03F", nullable: true, length: 1 })
  iam03F: string | null;

  @Column("varchar", { name: "IAM03U", nullable: true, length: 1 })
  iam03U: string | null;

  @Column("varchar", { name: "IAS03M", nullable: true, length: 1 })
  ias03M: string | null;

  @Column("varchar", { name: "IAS03F", nullable: true, length: 1 })
  ias03F: string | null;

  @Column("varchar", { name: "IAS03U", nullable: true, length: 1 })
  ias03U: string | null;

  @Column("varchar", { name: "IHI03M", nullable: true, length: 1 })
  ihi03M: string | null;

  @Column("varchar", { name: "IHI03F", nullable: true, length: 1 })
  ihi03F: string | null;

  @Column("varchar", { name: "IHI03U", nullable: true, length: 1 })
  ihi03U: string | null;

  @Column("varchar", { name: "IBL03M", nullable: true, length: 1 })
  ibl03M: string | null;

  @Column("varchar", { name: "IBL03F", nullable: true, length: 1 })
  ibl03F: string | null;

  @Column("varchar", { name: "IBL03U", nullable: true, length: 1 })
  ibl03U: string | null;

  @Column("varchar", { name: "IWH03M", nullable: true, length: 1 })
  iwh03M: string | null;

  @Column("varchar", { name: "IWH03F", nullable: true, length: 1 })
  iwh03F: string | null;

  @Column("varchar", { name: "IWH03U", nullable: true, length: 1 })
  iwh03U: string | null;

  @Column("varchar", { name: "IG04", nullable: true, length: 1 })
  ig04: string | null;

  @Column("varchar", { name: "IAM04M", nullable: true, length: 1 })
  iam04M: string | null;

  @Column("varchar", { name: "IAM04F", nullable: true, length: 1 })
  iam04F: string | null;

  @Column("varchar", { name: "IAM04U", nullable: true, length: 1 })
  iam04U: string | null;

  @Column("varchar", { name: "IAS04M", nullable: true, length: 1 })
  ias04M: string | null;

  @Column("varchar", { name: "IAS04F", nullable: true, length: 1 })
  ias04F: string | null;

  @Column("varchar", { name: "IAS04U", nullable: true, length: 1 })
  ias04U: string | null;

  @Column("varchar", { name: "IHI04M", nullable: true, length: 1 })
  ihi04M: string | null;

  @Column("varchar", { name: "IHI04F", nullable: true, length: 1 })
  ihi04F: string | null;

  @Column("varchar", { name: "IHI04U", nullable: true, length: 1 })
  ihi04U: string | null;

  @Column("varchar", { name: "IBL04M", nullable: true, length: 1 })
  ibl04M: string | null;

  @Column("varchar", { name: "IBL04F", nullable: true, length: 1 })
  ibl04F: string | null;

  @Column("varchar", { name: "IBL04U", nullable: true, length: 1 })
  ibl04U: string | null;

  @Column("varchar", { name: "IWH04M", nullable: true, length: 1 })
  iwh04M: string | null;

  @Column("varchar", { name: "IWH04F", nullable: true, length: 1 })
  iwh04F: string | null;

  @Column("varchar", { name: "IWH04U", nullable: true, length: 1 })
  iwh04U: string | null;

  @Column("varchar", { name: "IG05", nullable: true, length: 1 })
  ig05: string | null;

  @Column("varchar", { name: "IAM05M", nullable: true, length: 1 })
  iam05M: string | null;

  @Column("varchar", { name: "IAM05F", nullable: true, length: 1 })
  iam05F: string | null;

  @Column("varchar", { name: "IAM05U", nullable: true, length: 1 })
  iam05U: string | null;

  @Column("varchar", { name: "IAS05M", nullable: true, length: 1 })
  ias05M: string | null;

  @Column("varchar", { name: "IAS05F", nullable: true, length: 1 })
  ias05F: string | null;

  @Column("varchar", { name: "IAS05U", nullable: true, length: 1 })
  ias05U: string | null;

  @Column("varchar", { name: "IHI05M", nullable: true, length: 1 })
  ihi05M: string | null;

  @Column("varchar", { name: "IHI05F", nullable: true, length: 1 })
  ihi05F: string | null;

  @Column("varchar", { name: "IHI05U", nullable: true, length: 1 })
  ihi05U: string | null;

  @Column("varchar", { name: "IBL05M", nullable: true, length: 1 })
  ibl05M: string | null;

  @Column("varchar", { name: "IBL05F", nullable: true, length: 1 })
  ibl05F: string | null;

  @Column("varchar", { name: "IBL05U", nullable: true, length: 1 })
  ibl05U: string | null;

  @Column("varchar", { name: "IWH05M", nullable: true, length: 1 })
  iwh05M: string | null;

  @Column("varchar", { name: "IWH05F", nullable: true, length: 1 })
  iwh05F: string | null;

  @Column("varchar", { name: "IWH05U", nullable: true, length: 1 })
  iwh05U: string | null;

  @Column("varchar", { name: "IG06", nullable: true, length: 1 })
  ig06: string | null;

  @Column("varchar", { name: "IAM06M", nullable: true, length: 1 })
  iam06M: string | null;

  @Column("varchar", { name: "IAM06F", nullable: true, length: 1 })
  iam06F: string | null;

  @Column("varchar", { name: "IAM06U", nullable: true, length: 1 })
  iam06U: string | null;

  @Column("varchar", { name: "IAS06M", nullable: true, length: 1 })
  ias06M: string | null;

  @Column("varchar", { name: "IAS06F", nullable: true, length: 1 })
  ias06F: string | null;

  @Column("varchar", { name: "IAS06U", nullable: true, length: 1 })
  ias06U: string | null;

  @Column("varchar", { name: "IHI06M", nullable: true, length: 1 })
  ihi06M: string | null;

  @Column("varchar", { name: "IHI06F", nullable: true, length: 1 })
  ihi06F: string | null;

  @Column("varchar", { name: "IHI06U", nullable: true, length: 1 })
  ihi06U: string | null;

  @Column("varchar", { name: "IBL06M", nullable: true, length: 1 })
  ibl06M: string | null;

  @Column("varchar", { name: "IBL06F", nullable: true, length: 1 })
  ibl06F: string | null;

  @Column("varchar", { name: "IBL06U", nullable: true, length: 1 })
  ibl06U: string | null;

  @Column("varchar", { name: "IWH06M", nullable: true, length: 1 })
  iwh06M: string | null;

  @Column("varchar", { name: "IWH06F", nullable: true, length: 1 })
  iwh06F: string | null;

  @Column("varchar", { name: "IWH06U", nullable: true, length: 1 })
  iwh06U: string | null;

  @Column("varchar", { name: "IG07", nullable: true, length: 1 })
  ig07: string | null;

  @Column("varchar", { name: "IAM07M", nullable: true, length: 1 })
  iam07M: string | null;

  @Column("varchar", { name: "IAM07F", nullable: true, length: 1 })
  iam07F: string | null;

  @Column("varchar", { name: "IAM07U", nullable: true, length: 1 })
  iam07U: string | null;

  @Column("varchar", { name: "IAS07M", nullable: true, length: 1 })
  ias07M: string | null;

  @Column("varchar", { name: "IAS07F", nullable: true, length: 1 })
  ias07F: string | null;

  @Column("varchar", { name: "IAS07U", nullable: true, length: 1 })
  ias07U: string | null;

  @Column("varchar", { name: "IHI07M", nullable: true, length: 1 })
  ihi07M: string | null;

  @Column("varchar", { name: "IHI07F", nullable: true, length: 1 })
  ihi07F: string | null;

  @Column("varchar", { name: "IHI07U", nullable: true, length: 1 })
  ihi07U: string | null;

  @Column("varchar", { name: "IBL07M", nullable: true, length: 1 })
  ibl07M: string | null;

  @Column("varchar", { name: "IBL07F", nullable: true, length: 1 })
  ibl07F: string | null;

  @Column("varchar", { name: "IBL07U", nullable: true, length: 1 })
  ibl07U: string | null;

  @Column("varchar", { name: "IWH07M", nullable: true, length: 1 })
  iwh07M: string | null;

  @Column("varchar", { name: "IWH07F", nullable: true, length: 1 })
  iwh07F: string | null;

  @Column("varchar", { name: "IWH07U", nullable: true, length: 1 })
  iwh07U: string | null;

  @Column("varchar", { name: "IG08", nullable: true, length: 1 })
  ig08: string | null;

  @Column("varchar", { name: "IAM08M", nullable: true, length: 1 })
  iam08M: string | null;

  @Column("varchar", { name: "IAM08F", nullable: true, length: 1 })
  iam08F: string | null;

  @Column("varchar", { name: "IAM08U", nullable: true, length: 1 })
  iam08U: string | null;

  @Column("varchar", { name: "IAS08M", nullable: true, length: 1 })
  ias08M: string | null;

  @Column("varchar", { name: "IAS08F", nullable: true, length: 1 })
  ias08F: string | null;

  @Column("varchar", { name: "IAS08U", nullable: true, length: 1 })
  ias08U: string | null;

  @Column("varchar", { name: "IHI08M", nullable: true, length: 1 })
  ihi08M: string | null;

  @Column("varchar", { name: "IHI08F", nullable: true, length: 1 })
  ihi08F: string | null;

  @Column("varchar", { name: "IHI08U", nullable: true, length: 1 })
  ihi08U: string | null;

  @Column("varchar", { name: "IBL08M", nullable: true, length: 1 })
  ibl08M: string | null;

  @Column("varchar", { name: "IBL08F", nullable: true, length: 1 })
  ibl08F: string | null;

  @Column("varchar", { name: "IBL08U", nullable: true, length: 1 })
  ibl08U: string | null;

  @Column("varchar", { name: "IWH08M", nullable: true, length: 1 })
  iwh08M: string | null;

  @Column("varchar", { name: "IWH08F", nullable: true, length: 1 })
  iwh08F: string | null;

  @Column("varchar", { name: "IWH08U", nullable: true, length: 1 })
  iwh08U: string | null;

  @Column("varchar", { name: "IG09", nullable: true, length: 1 })
  ig09: string | null;

  @Column("varchar", { name: "IAM09M", nullable: true, length: 1 })
  iam09M: string | null;

  @Column("varchar", { name: "IAM09F", nullable: true, length: 1 })
  iam09F: string | null;

  @Column("varchar", { name: "IAM09U", nullable: true, length: 1 })
  iam09U: string | null;

  @Column("varchar", { name: "IAS09M", nullable: true, length: 1 })
  ias09M: string | null;

  @Column("varchar", { name: "IAS09F", nullable: true, length: 1 })
  ias09F: string | null;

  @Column("varchar", { name: "IAS09U", nullable: true, length: 1 })
  ias09U: string | null;

  @Column("varchar", { name: "IHI09M", nullable: true, length: 1 })
  ihi09M: string | null;

  @Column("varchar", { name: "IHI09F", nullable: true, length: 1 })
  ihi09F: string | null;

  @Column("varchar", { name: "IHI09U", nullable: true, length: 1 })
  ihi09U: string | null;

  @Column("varchar", { name: "IBL09M", nullable: true, length: 1 })
  ibl09M: string | null;

  @Column("varchar", { name: "IBL09F", nullable: true, length: 1 })
  ibl09F: string | null;

  @Column("varchar", { name: "IBL09U", nullable: true, length: 1 })
  ibl09U: string | null;

  @Column("varchar", { name: "IWH09M", nullable: true, length: 1 })
  iwh09M: string | null;

  @Column("varchar", { name: "IWH09F", nullable: true, length: 1 })
  iwh09F: string | null;

  @Column("varchar", { name: "IWH09U", nullable: true, length: 1 })
  iwh09U: string | null;

  @Column("varchar", { name: "IG10", nullable: true, length: 1 })
  ig10: string | null;

  @Column("varchar", { name: "IAM10M", nullable: true, length: 1 })
  iam10M: string | null;

  @Column("varchar", { name: "IAM10F", nullable: true, length: 1 })
  iam10F: string | null;

  @Column("varchar", { name: "IAM10U", nullable: true, length: 1 })
  iam10U: string | null;

  @Column("varchar", { name: "IAS10M", nullable: true, length: 1 })
  ias10M: string | null;

  @Column("varchar", { name: "IAS10F", nullable: true, length: 1 })
  ias10F: string | null;

  @Column("varchar", { name: "IAS10U", nullable: true, length: 1 })
  ias10U: string | null;

  @Column("varchar", { name: "IHI10M", nullable: true, length: 1 })
  ihi10M: string | null;

  @Column("varchar", { name: "IHI10F", nullable: true, length: 1 })
  ihi10F: string | null;

  @Column("varchar", { name: "IHI10U", nullable: true, length: 1 })
  ihi10U: string | null;

  @Column("varchar", { name: "IBL10M", nullable: true, length: 1 })
  ibl10M: string | null;

  @Column("varchar", { name: "IBL10F", nullable: true, length: 1 })
  ibl10F: string | null;

  @Column("varchar", { name: "IBL10U", nullable: true, length: 1 })
  ibl10U: string | null;

  @Column("varchar", { name: "IWH10M", nullable: true, length: 1 })
  iwh10M: string | null;

  @Column("varchar", { name: "IWH10F", nullable: true, length: 1 })
  iwh10F: string | null;

  @Column("varchar", { name: "IWH10U", nullable: true, length: 1 })
  iwh10U: string | null;

  @Column("varchar", { name: "IG11", nullable: true, length: 1 })
  ig11: string | null;

  @Column("varchar", { name: "IAM11M", nullable: true, length: 1 })
  iam11M: string | null;

  @Column("varchar", { name: "IAM11F", nullable: true, length: 1 })
  iam11F: string | null;

  @Column("varchar", { name: "IAM11U", nullable: true, length: 1 })
  iam11U: string | null;

  @Column("varchar", { name: "IAS11M", nullable: true, length: 1 })
  ias11M: string | null;

  @Column("varchar", { name: "IAS11F", nullable: true, length: 1 })
  ias11F: string | null;

  @Column("varchar", { name: "IAS11U", nullable: true, length: 1 })
  ias11U: string | null;

  @Column("varchar", { name: "IHI11M", nullable: true, length: 1 })
  ihi11M: string | null;

  @Column("varchar", { name: "IHI11F", nullable: true, length: 1 })
  ihi11F: string | null;

  @Column("varchar", { name: "IHI11U", nullable: true, length: 1 })
  ihi11U: string | null;

  @Column("varchar", { name: "IBL11M", nullable: true, length: 1 })
  ibl11M: string | null;

  @Column("varchar", { name: "IBL11F", nullable: true, length: 1 })
  ibl11F: string | null;

  @Column("varchar", { name: "IBL11U", nullable: true, length: 1 })
  ibl11U: string | null;

  @Column("varchar", { name: "IWH11M", nullable: true, length: 1 })
  iwh11M: string | null;

  @Column("varchar", { name: "IWH11F", nullable: true, length: 1 })
  iwh11F: string | null;

  @Column("varchar", { name: "IWH11U", nullable: true, length: 1 })
  iwh11U: string | null;

  @Column("varchar", { name: "IG12", nullable: true, length: 1 })
  ig12: string | null;

  @Column("varchar", { name: "IAM12M", nullable: true, length: 1 })
  iam12M: string | null;

  @Column("varchar", { name: "IAM12F", nullable: true, length: 1 })
  iam12F: string | null;

  @Column("varchar", { name: "IAM12U", nullable: true, length: 1 })
  iam12U: string | null;

  @Column("varchar", { name: "IAS12M", nullable: true, length: 1 })
  ias12M: string | null;

  @Column("varchar", { name: "IAS12F", nullable: true, length: 1 })
  ias12F: string | null;

  @Column("varchar", { name: "IAS12U", nullable: true, length: 1 })
  ias12U: string | null;

  @Column("varchar", { name: "IHI12M", nullable: true, length: 1 })
  ihi12M: string | null;

  @Column("varchar", { name: "IHI12F", nullable: true, length: 1 })
  ihi12F: string | null;

  @Column("varchar", { name: "IHI12U", nullable: true, length: 1 })
  ihi12U: string | null;

  @Column("varchar", { name: "IBL12M", nullable: true, length: 1 })
  ibl12M: string | null;

  @Column("varchar", { name: "IBL12F", nullable: true, length: 1 })
  ibl12F: string | null;

  @Column("varchar", { name: "IBL12U", nullable: true, length: 1 })
  ibl12U: string | null;

  @Column("varchar", { name: "IWH12M", nullable: true, length: 1 })
  iwh12M: string | null;

  @Column("varchar", { name: "IWH12F", nullable: true, length: 1 })
  iwh12F: string | null;

  @Column("varchar", { name: "IWH12U", nullable: true, length: 1 })
  iwh12U: string | null;

  @Column("varchar", { name: "IUG", nullable: true, length: 1 })
  iug: string | null;

  @Column("varchar", { name: "IAMUGM", nullable: true, length: 1 })
  iamugm: string | null;

  @Column("varchar", { name: "IAMUGF", nullable: true, length: 1 })
  iamugf: string | null;

  @Column("varchar", { name: "IAMUGU", nullable: true, length: 1 })
  iamugu: string | null;

  @Column("varchar", { name: "IASUGM", nullable: true, length: 1 })
  iasugm: string | null;

  @Column("varchar", { name: "IASUGF", nullable: true, length: 1 })
  iasugf: string | null;

  @Column("varchar", { name: "IASUGU", nullable: true, length: 1 })
  iasugu: string | null;

  @Column("varchar", { name: "IHIUGM", nullable: true, length: 1 })
  ihiugm: string | null;

  @Column("varchar", { name: "IHIUGF", nullable: true, length: 1 })
  ihiugf: string | null;

  @Column("varchar", { name: "IHIUGU", nullable: true, length: 1 })
  ihiugu: string | null;

  @Column("varchar", { name: "IBLUGM", nullable: true, length: 1 })
  iblugm: string | null;

  @Column("varchar", { name: "IBLUGF", nullable: true, length: 1 })
  iblugf: string | null;

  @Column("varchar", { name: "IBLUGU", nullable: true, length: 1 })
  iblugu: string | null;

  @Column("varchar", { name: "IWHUGM", nullable: true, length: 1 })
  iwhugm: string | null;

  @Column("varchar", { name: "IWHUGF", nullable: true, length: 1 })
  iwhugf: string | null;

  @Column("varchar", { name: "IWHUGU", nullable: true, length: 1 })
  iwhugu: string | null;

  @Column("varchar", { name: "IMEMB", nullable: true, length: 1 })
  imemb: string | null;

  @Column("varchar", { name: "IAM", nullable: true, length: 1 })
  iam: string | null;

  @Column("varchar", { name: "IAMALM", nullable: true, length: 1 })
  iamalm: string | null;

  @Column("varchar", { name: "IAMALF", nullable: true, length: 1 })
  iamalf: string | null;

  @Column("varchar", { name: "IAMALU", nullable: true, length: 1 })
  iamalu: string | null;

  @Column("varchar", { name: "IASIAN", nullable: true, length: 1 })
  iasian: string | null;

  @Column("varchar", { name: "IASALM", nullable: true, length: 1 })
  iasalm: string | null;

  @Column("varchar", { name: "IASALF", nullable: true, length: 1 })
  iasalf: string | null;

  @Column("varchar", { name: "IASALU", nullable: true, length: 1 })
  iasalu: string | null;

  @Column("varchar", { name: "IHISP", nullable: true, length: 1 })
  ihisp: string | null;

  @Column("varchar", { name: "IHIALM", nullable: true, length: 1 })
  ihialm: string | null;

  @Column("varchar", { name: "IHIALF", nullable: true, length: 1 })
  ihialf: string | null;

  @Column("varchar", { name: "IHIALU", nullable: true, length: 1 })
  ihialu: string | null;

  @Column("varchar", { name: "IBLACK", nullable: true, length: 1 })
  iblack: string | null;

  @Column("varchar", { name: "IBLALM", nullable: true, length: 1 })
  iblalm: string | null;

  @Column("varchar", { name: "IBLALF", nullable: true, length: 1 })
  iblalf: string | null;

  @Column("varchar", { name: "IBLALU", nullable: true, length: 1 })
  iblalu: string | null;

  @Column("varchar", { name: "IWHITE", nullable: true, length: 1 })
  iwhite: string | null;

  @Column("varchar", { name: "IWHALM", nullable: true, length: 1 })
  iwhalm: string | null;

  @Column("varchar", { name: "IWHALF", nullable: true, length: 1 })
  iwhalf: string | null;

  @Column("varchar", { name: "IWHALU", nullable: true, length: 1 })
  iwhalu: string | null;

  @Column("varchar", { name: "IETH", nullable: true, length: 1 })
  ieth: string | null;

  @Column("varchar", { name: "IPUTCH", nullable: true, length: 1 })
  iputch: string | null;

  @Column("varchar", { name: "ITOTGR", nullable: true, length: 1 })
  itotgr: string | null;
}
