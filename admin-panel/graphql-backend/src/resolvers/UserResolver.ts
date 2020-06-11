// src/resolvers/UserResolver.ts


// import { Resolver, Query, Mutation, Arg, Args, ObjectType, Field, FieldResolver, Root, ID } from "type-graphql"
import {
  ArgsType, InputType, ID,
  Resolver, Query, Mutation, Arg,
  Args, ObjectType, Field, Authorized
} from "type-graphql"

import { User } from "../entities/Users"
import { AdminProject } from "../entities/AdminProjects"

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
  projectsIds: string[]
}

@InputType()
class UserFilter implements Partial<User>{
  @Field(type => ID)
  id?: number;

  @Field(type => String)
  email?: string;

  @Field(type => String)
  lastName?: string;

  @Field(type => String)
  firstName?: string;
}

type UserSortField = "firstName" | "lastName" | "id"

type SortOrder = "ASC" | "DESC"


@ArgsType()
class GenericPaginationAndFilter {
  @Field(type => UserFilter)
  filter?: UserFilter

  // Important, this is zero-indexed
  @Field({defaultValue: 0})
  page: number

  @Field({defaultValue: 10})
  perPage: number

  @Field({defaultValue: 'id'})
  sortField: UserSortField

  @Field({defaultValue: "ASC"})
  sortOrder: SortOrder
}


@ArgsType()
class UpdateUser extends CreateUser{
  @Field()
  id: number
}

@ObjectType()
class userListMeta {
  @Field(() => Number)
  count: number
}


@Resolver(of => User)
export class UserResolver {
  @Authorized()
  @Query(() => [User])
  async allUsers(@Args() {filter, page, perPage, sortField, sortOrder}:GenericPaginationAndFilter) {
    const found = await User.find({
      order: { [sortField]: sortOrder },
      where: filter,
      take: perPage,
      skip: page * perPage,
      relations: ["projects"]
    })
    return found
  }

  @Authorized()
  @Query(() => userListMeta)
  _allUsersMeta(@Args() {page, perPage}:GenericPaginationAndFilter){
    return {count: User.count()}
  }

  @Authorized()
  @Query(() => User)
  User(@Arg("id") id: string) {
    return User.findOne({ where: { id }, relations: ["projects"]});
  }

  @Authorized()
  @Mutation(() => Boolean)
  async deleteUser(@Arg("id") id: string) {
    const user = await User.findOne({ where: { id } });
    if (!user) throw new Error("User not found!");
    await user.remove();
    return true;
  }

  @Authorized()
  @Mutation(() => User)
  async createUser(
    @Args()
    {firstName, lastName, email, projectsIds }: CreateUser)
    {
      const params = {firstName, lastName, email}
      const user = User.create(params);
      await user.save();
      return user;
  }

  @Authorized()
  @Mutation(() => User)
  async updateUser(
    @Args()
    {id, firstName, lastName, email, projectsIds }: UpdateUser)
    {
      const params = {firstName, lastName, email }
      const user = await User.findOne({ where: { id } });
      if (!user) throw new Error("User not found!");
      Object.assign(user, params);
      user.projects = await AdminProject.findByIds(projectsIds)
      await user.save();
      return user;
  }

}
