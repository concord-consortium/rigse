// src/resolvers/PortalStudentResolver.ts


// import { Resolver, Query, Mutation, Arg, Args, ObjectType, Field, FieldResolver, Root, ID } from "type-graphql"
import {
  ArgsType, InputType, ID, Resolver, Query, Mutation, Arg,
  Args, Field, Authorized } from "type-graphql"
import { In } from "typeorm"
import { PortalStudent } from "../entities/PortalStudents"
import { AdminProject } from "../entities/AdminProjects"
import { User } from "../entities/Users"
import { updateEntity, fuzzyCount,
  fuzzyFetch, PaginationAndFilter} from "../helpers/entityResolverHelpers"
import { listMeta } from "../helpers/listMeta"

@ArgsType()
class CreatePortalStudent implements Partial<PortalStudent>{
  @Field( Type => [ID])
  userId: number
}

@ArgsType()
class UpdatePortalStudent extends CreatePortalStudent{
  @Field(type => ID)
  id: number
}


@InputType()
class PortalStudentFilter implements Partial<PortalStudent>{
  @Field(type => ID)
  id?: number;

  @Field(type => [ID])
  ids?: number[];

  @Field(type => ID)
  userId?:  number;
}

@ArgsType()
class PortalStudentPaginationAndFilter extends PaginationAndFilter {
  @Field(type => PortalStudentFilter)
  filter?: PortalStudentFilter
}


@Resolver(of => PortalStudent)
export class PortalStudentResolver {
  @Authorized()
  @Query(() => [PortalStudent])
  async allPortalStudents(@Args() searchParams:PortalStudentPaginationAndFilter) {
    const {filter} = searchParams
    const relations = ["user"];
    let where = {}
    let findParams: {ids?:any, where:any, relations:string[]} = {where, relations}
    if(filter && filter.userId) {
      where = { userId: filter.userId }
    }
    if(filter && filter.id) {
      where = { id: filter.id }
    }
    if(filter && filter.ids) {
      findParams.ids = In(filter.ids)
    }
    return PortalStudent.find({where, relations})
  }

  @Authorized()
  @Query(() => listMeta)
  async _allPortalStudentsMeta(@Args() searchParams:PortalStudentPaginationAndFilter){
    const count = await fuzzyCount<PortalStudent>(PortalStudent, 'PortalStudent', searchParams);
    return {count}
  }

  @Authorized()
  @Query(() => PortalStudent)
  PortalStudent(@Arg("id") id: string) {
    return PortalStudent.findOne({ where: { id }, relations: ["user"]});
  }

  @Authorized()
  @Mutation(() => PortalStudent)
  async deletePortalStudent(@Arg("id") id: string) {
    const portalStudent = await PortalStudent.findOne({
      where: { id }
    });

    if (!portalStudent) throw new Error("PortalStudent not found!");
    portalStudent.remove();
    return portalStudent;
  }

  @Authorized()
  @Mutation(() => PortalStudent)
  async createPortalStudent(
    @Args()
    {userId}: CreatePortalStudent)
    {
      const params = {userId}
      return updateEntity<PortalStudent>(PortalStudent, params);
  }

  @Authorized()
  @Mutation(() => PortalStudent)
  async updatePortalStudent(
    @Args()
    {userId}: UpdatePortalStudent)
    {
      const params = {userId}
      const associationCallback = async (PortalStudent: PortalStudent) => {
        PortalStudent.user = await User.findOne(userId)
        return PortalStudent
      }
      return updateEntity<PortalStudent>(PortalStudent, params, associationCallback);
  }

}
