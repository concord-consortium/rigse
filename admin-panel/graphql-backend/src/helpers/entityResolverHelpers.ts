import { BaseEntity, FindOneOptions, ObjectType, getConnection, Table, SelectQueryBuilder } from "typeorm"
import { ArgsType, InputType, Field} from "type-graphql"

interface IPortalFields {
  id: number;
  createdAt: Date;
  updatedAt: Date;
}

abstract class PortalEntity extends BaseEntity implements IPortalFields {
  id: number;
  createdAt: Date;
  updatedAt: Date;
}

function isValidDate(d: any) {
  return d instanceof Date && !isNaN((d as unknown) as number);
}

function timeStamps<T extends PortalEntity>(entity: T, params: Partial<T>) {
  if(isValidDate(entity.createdAt)) {
    params.createdAt = new Date()
  }
  params.updatedAt = new Date()
  return params
}

// This interface is mostly stolen from BaseEntity DT
interface OrmCLass<T extends BaseEntity> {
  findOne(params: FindOneOptions<T>): Promise<T | undefined>
  create(params: Partial<T>): T;
}

export async function updateEntity<T extends PortalEntity>(
  clazz: OrmCLass<T>,
  params: Partial<T>,
  associationsCallback?: (entity: T) => Promise<T>
  ) {
  let entity: T | undefined = undefined
  try {
    if(params.id && params.id !== null) {
      // Update an existing record
      entity = await clazz.findOne({ where: {id: params.id}})
      delete(params.id)
    }
    else {
      // Create a new record
      entity = clazz.create(params)
    }
    if(entity) {
      params = timeStamps<T>(entity, params)
      Object.assign(entity, params);
      if(associationsCallback) {
        entity = await associationsCallback(entity);
      }
      return await entity.save();
    }
  }
  catch(e) {
    console.log(e)
    throw(e)
  }
}

export interface StringFilter {
  [key: string]: string | string[]
}

export type SortOrder = "ASC" | "DESC"

export interface IPaginationAndFilter {
  filter?: StringFilter
  page: number
  perPage: number
  sortField: string
  sortOrder: SortOrder
}

@ArgsType()
export class PaginationAndFilter {
  // Important, this is zero-indexed
  @Field({defaultValue: 0})
  page: number

  @Field({defaultValue: 10})
  perPage: number

  @Field({defaultValue: 'id'})
  sortField: string

  @Field({defaultValue: "ASC"})
  sortOrder: SortOrder
}

async function buildQuery
  <T extends PortalEntity>(
  clazz: ObjectType<T>,
  table: string,
  {filter, page, perPage, sortField, sortOrder}:IPaginationAndFilter)
  : Promise<SelectQueryBuilder<T>>{
  const filterFields = Object.keys(filter || {})
  const wheres: string[] = []
  const parameters: {[key:string]: string } = {}
  const repository = getConnection().getRepository(clazz)
  filterFields.forEach( fieldName => {
    // For now special case the 'ids' field in the filter for association lookup
    // we could do something generic with any array fieldName later....
    if(fieldName === 'ids') {
      if(filter && filter.ids.length > 0) {
        wheres.push(`${table}.id in (:ID_LIST)`)
        parameters['ID_LIST'] = (filter.ids as string[]).join(',');
      }
    } else {
      if((filter as any)[fieldName].length > 0) {
        wheres.push(`${table}.${fieldName} LIKE :${fieldName}Param`)
        parameters[`${fieldName}Param`] = `%${(filter as any)[fieldName]}%`
      }
    }

  })
  const query =  await repository.createQueryBuilder(table)
    .where(wheres.join( " AND "))
    .setParameters(parameters)
    .orderBy(`${table}.${sortField}`, sortOrder)
    .skip(page * perPage)
    .take(perPage)
  return query
}

export async function fuzzyFetch
  <T extends PortalEntity>(
  clazz: ObjectType<T>,
  table: string,
  params: PaginationAndFilter): Promise<T[]>{
    const query =  await buildQuery<T>(clazz, table, params)
    const results = await query.getMany()
    return results
}

export async function fuzzyCount
  <T extends PortalEntity>(
  clazz: ObjectType<T>,
  table: string,
  params: PaginationAndFilter): Promise<number>{
  const query =  await buildQuery<T>(clazz, table, params)
  const count =  await query.getCount()
  return count
}

