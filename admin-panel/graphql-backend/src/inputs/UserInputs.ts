import { ArgsType, Field, ID } from "type-graphql"
import { User } from "../entities/Users"
@ArgsType()
export class UpdateUser implements Partial<User>{
  @Field()
  id: number

  @Field()
  firstName: string

  @Field()
  lastName: string

  @Field()
  email: string

  @Field( Type => [ID])
  projectsIds: string[]
}
