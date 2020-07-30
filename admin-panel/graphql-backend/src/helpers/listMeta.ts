import { ObjectType, Field } from "type-graphql"

@ObjectType()
export class listMeta {
  @Field(() => Number)
  count: number
}