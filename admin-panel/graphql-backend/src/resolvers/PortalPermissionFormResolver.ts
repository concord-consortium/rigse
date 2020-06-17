// src/resolvers/PortalPermissionFormResolver.ts
// import { Resolver, Query, Mutation, Arg, Args, ObjectType, Field, FieldResolver, Root, ID } from "type-graphql"
import {
  ArgsType, InputType, ID,
  Resolver, Query, Mutation, Arg,
  Args, ObjectType, Field, Authorized
} from "type-graphql"

import { getConnection } from "typeorm";
import { PortalPermissionForm } from "../entities/PortalPermissionForms"
import { AdminProject} from "../entities/AdminProjects"

@ArgsType()
class CreatePortalPermissionForm implements Partial<PortalPermissionForm>{
  @Field()
  name: string

  @Field()
  url: string

  @Field( Type => ID)
  projectId: number
}

@InputType()
class PortalPermissionFormFilter implements Partial<PortalPermissionForm>{
  @Field(type => String)
  name?: string;
}

type PortalPermissionFormSortField = "name"
type SortOrder = "ASC" | "DESC"


@ArgsType()
class PaginationAndFilter {
  @Field(type => PortalPermissionFormFilter)
  filter?: PortalPermissionFormFilter

  // Important, this is zero-indexed
  @Field({defaultValue: 0})
  page: number

  @Field({defaultValue: 10})
  perPage: number

  @Field({defaultValue: 'id'})
  sortField: PortalPermissionFormSortField

  @Field({defaultValue: "ASC"})
  sortOrder: SortOrder
}


@ArgsType()
class UpdatePortalPermissionForm extends CreatePortalPermissionForm{
  @Field(Type => ID)
  id: number
}

@ObjectType()
class PortalPermissionFormListMeta {
  @Field(() => Number)
  count: number
}

const buildQuery = async ({filter, page, perPage, sortField, sortOrder}:PaginationAndFilter) => {
  const table =  'portal_permission_forms'
  const fuzzyFields = ["name"]
  const wheres: string[] = []
  const parameters: {[key:string]: string } = {}
  const repository = getConnection().getRepository(PortalPermissionForm)
  const fuzzyParams = fuzzyFields.forEach( fieldName => {
    if((filter as any)[fieldName] && (filter as any)[fieldName].length > 0) {
      wheres.push(`${table}.${fieldName} LIKE :${fieldName}Param`)
      parameters[`${fieldName}Param`] = `%${(filter as any)[fieldName]}%`
    }
  })
  return await repository.createQueryBuilder(table)
    .where(wheres.join( " AND "))
    .setParameters(parameters)
    .orderBy(`${table}.${sortField}`, "ASC")
    .skip(page * perPage)
    .take(perPage)
}

const fuzzyFetch = async (params: PaginationAndFilter) => {
  const query =  await buildQuery(params)
  return query.getMany()
}

const fuzzyCount = async (params: PaginationAndFilter) => {
  const query =  await buildQuery(params)
  return query.getCount()
}

@Resolver(of => PortalPermissionForm)
export class PortalPermissionFormResolver {
  @Authorized()
  @Query(() => [PortalPermissionForm])
  async allPortalPermissionForms(@Args() searchParams:PaginationAndFilter) {
    return await fuzzyFetch(searchParams);
  }

  @Authorized()
  @Query(() => PortalPermissionFormListMeta)
  _allPortalPermissionFormsMeta(@Args() searchParams:PaginationAndFilter){
    const count = fuzzyCount(searchParams)
    return {count}
  }

  @Authorized()
  @Query(() => PortalPermissionForm)
  PortalPermissionForm(@Arg("id") id: string) {
    return PortalPermissionForm.findOne({ where: { id }, relations: ["project"]});
  }

  @Authorized()
  @Mutation(() => Boolean)
  async deletePortalPermissionForm(@Arg("id") id: string) {
    const permForm = await PortalPermissionForm.findOne({ where: { id } });
    if (!PortalPermissionForm) throw new Error("PortalPermissionForm not found!");
    if(permForm) {
      await permForm.remove();
    }
    return true;
  }

  @Authorized()
  @Mutation(() => PortalPermissionForm)
  async createPortalPermissionForm(
    @Args()
    params: CreatePortalPermissionForm)
    {
      const permissionForm = PortalPermissionForm.create(params);
      await permissionForm.save();
      return PortalPermissionForm;
  }

  @Authorized()
  @Mutation(() => PortalPermissionForm)
  async updatePortalPermissionForm(
    @Args()
    params: UpdatePortalPermissionForm)
    {
      const {name, url, projectId, id} = params;
      const updateParams = {name, url, projectId}
      const permissionForm = await PortalPermissionForm.findOne({ where: { id } });
      if (!permissionForm) throw new Error("PortalPermissionForm not found!");
      const timeStamps = {
        updatedAt: new Date(),
        createdAt: permissionForm.createdAt || new Date()
      }
      Object.assign(permissionForm, updateParams, timeStamps);
      const project = await AdminProject.findOne({where: {id: projectId}})
      if(project) {
        permissionForm.project = project
      }
      try {
        await permissionForm.save();
      }
      catch(e) {
        console.log(e)
      }
      return permissionForm;
  }

}
