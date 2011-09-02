##
## Factories that have to do with setting up external_user_domains.
##

Factory.sequence(:name)        { |n| "external-server#{n}" }
Factory.sequence(:description) { |n| "A test domain: external-server#{n}, representing an external server instance." }
Factory.sequence(:server_url)  { |n| "http://external-server#{n}.edu" }

##
## Factory for external_user_domain
##
Factory.define :external_user_domain, :class => ExternalUserDomain do |eud|
  eud.name        { Factory.next(:name) }
  eud.description { Factory.next(:description) }
  eud.server_url  { Factory.next(:server_url) }
end
