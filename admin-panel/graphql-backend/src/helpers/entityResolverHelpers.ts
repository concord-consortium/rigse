import { BaseEntity, FindOneOptions, ObjectType } from "typeorm"

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
