// src/resolvers/PortalPermissionFormResolver.ts
// import { Resolver, Query, Mutation, Arg, Args, ObjectType, Field, FieldResolver, Root, ID } from "type-graphql"
import {
  ArgsType, InputType, ID,
  Resolver, Query, Mutation, Arg,
  Args, ObjectType, Field, Authorized
} from "type-graphql"
import { listMeta } from "../helpers/listMeta"
import { PortalPermissionForm } from "../entities/PortalPermissionForms"
import { updateEntity, PaginationAndFilter, fuzzyFetch, fuzzyCount } from "../helpers/entityResolverHelpers"
import { PortalSchoolMemberships } from "../entities/unused/PortalSchoolMemberships";

@ArgsType()
class CreatePortalPermissionForm implements Partial<PortalPermissionForm>{
  @Field()
  name: string

  @Field()
  url: string

  @Field(Type => ID)
  projectId?: number
}

@InputType()
class PermissionFilter implements Partial<PortalPermissionForm>{
  @Field(type => String)
  name?: string;
}

@ArgsType()
class PermissionSearch extends PaginationAndFilter {
  @Field(type => PermissionFilter)
  filter?: PermissionFilter
}

@ArgsType()
class UpdatePortalPermissionForm extends CreatePortalPermissionForm{
  @Field(Type => ID)
  id: number
}

@Resolver(of => PortalPermissionForm)
export class PortalPermissionFormResolver {
  @Authorized()
  @Query(() => [PortalPermissionForm])
  async allPortalPermissionForms(@Args() searchParams:PermissionSearch) {
    return await fuzzyFetch<PortalPermissionForm>(PortalPermissionForm, 'portalPermissionForm', searchParams);
  }

  @Authorized()
  @Query(() => listMeta)
  async _allPortalPermissionFormsMeta(@Args() searchParams:PermissionSearch){
    const count =  await fuzzyCount<PortalPermissionForm>(PortalPermissionForm, 'portalPermissionForm', searchParams);
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
    params: CreatePortalPermissionForm) {
      return updateEntity<PortalPermissionForm>(PortalPermissionForm, params)
  }

  @Authorized()
  @Mutation(() => PortalPermissionForm)
  async updatePortalPermissionForm(
    @Args()
    params: UpdatePortalPermissionForm) {
      return updateEntity<PortalPermissionForm>(PortalPermissionForm, params)
  }

}
