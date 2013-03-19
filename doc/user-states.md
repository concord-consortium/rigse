## User states ##

Possible user states:

 - passive
 - pending
 - active
 - suspended
 - disabled


----------

State: passive
Description: This is the first state a user is in when first created.
             It is a Devise-only state as it is immediately reset to 'pending' through code.
Set when: A new user is created.


State: pending
Description: Indicates has not yet activated the account using the activation link sent via email.
Set when: A new user is created.


State: active
Description: Indicates the user is active and can log into the portal.
Set when: Either set directly (for users like students) or via activation links (for teachers).


State: suspended
Description: Indicates the user has been suspended by the portal admin.
Set when: The admin suspends the user via the admin pages.


State: disabled
Description: Indicates the user has been soft-deleted.
Set when: The user is deleted.
