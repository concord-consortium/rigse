// src/resolvers/UserResolver.ts


// import { Resolver, Query, Mutation, Arg, Args, ObjectType, Field, FieldResolver, Root, ID } from "type-graphql"
import {
  ArgsType, InputType, ID, Resolver, Query, Mutation, Arg,
  Args, Field, Authorized } from "type-graphql"
import { User } from "../entities/Users"
import { AdminProject } from "../entities/AdminProjects"
import { updateEntity, fuzzyCount,
  fuzzyFetch, PaginationAndFilter} from "../helpers/entityResolverHelpers"
import { listMeta } from "../helpers/listMeta"

@ArgsType()
class CreateUser implements Partial<User>{
  @Field()
  firstName: string

  @Field()
  lastName: string

  @Field()
  email: string

  @Field()
  login: string

  @Field( Type => [ID])
  projectsIds: number[]
}

@ArgsType()
class UpdateUser extends CreateUser{
  @Field(type => ID)
  id: number
}


@InputType()
class UserFilter implements Partial<User>{
  @Field(type => [ID])
  ids?: number[];

  @Field(type => String)
  email?: string;

  @Field(type => String)
  lastName?: string;

  @Field(type => String)
  firstName?: string;
}

@ArgsType()
class UserPaginationAndFilter extends PaginationAndFilter {
  @Field(type => UserFilter)
  filter?: UserFilter
}


@Resolver(of => User)
export class UserResolver {
  @Authorized()
  @Query(() => [User])
  async allUsers(@Args() searchParams:UserPaginationAndFilter) {
    return await fuzzyFetch<User>(User, 'user', searchParams);
  }

  @Authorized()
  @Query(() => listMeta)
  async _allUsersMeta(@Args() searchParams:UserPaginationAndFilter){
    const count = await fuzzyCount<User>(User, 'user', searchParams);
    return {count}
  }

  @Authorized()
  @Query(() => User)
  User(@Arg("id") id: string) {
    return User.findOne({ where: { id }, relations: ["projects"]});
  }

  @Authorized()
  @Mutation(() => User)
  async deleteUser(@Arg("id") id: string) {
    const user = await User.findOne({ where: { id } });
    if (!user) throw new Error("User not found!");
    user.remove();
    return user;
  }

  @Authorized()
  @Mutation(() => User)
  async createUser(
    @Args()
    {firstName, lastName, email }: CreateUser)
    {
      const params = {firstName, lastName, email}
      return updateEntity<User>(User, params);
  }

  @Authorized()
  @Mutation(() => User)
  async updateUser(
    @Args()
    {id, firstName, lastName, email, projectsIds }: UpdateUser)
    {
      const params = {id, firstName, lastName, email }
      const associationCallback = async (user: User) => {
        user.projects = await AdminProject.findByIds(projectsIds)
        return user
      }
      return updateEntity<User>(User, params, associationCallback);
  }

}
