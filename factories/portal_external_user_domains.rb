##
## Factories that have to do with setting up external_user_domains.
##

Factory.sequence(:name)        { |n| "sakai-server#{n}" }
Factory.sequence(:description) { |n| "A test domain: sakai-server#{n}, representing an external sakai instance." }
Factory.sequence(:server_url)  { |n| "http://sakai-server#{n}.edu" }

##
## Factory for external_user_domain
##
Factory.define :portal_external_user_domain, :class => Portal::ExternalUserDomain do |eud|
  eud.name        { Factory.next(:name) }
  eud.description { Factory.next(:description) }
  eud.server_url  { Factory.next(:server_url) }
end
