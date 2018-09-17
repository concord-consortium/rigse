# This file defines the minimum set of data needed for an 
# An Investigations Instance to boot (in the 'test' environement)
# also includes a few samples of how to instantiate singletons like
# Anonymous and Admin users...
# Many factory calls chain other factory calls to create dependant objects.
# couldn' get that to work for admin_settings though! 
# ( FactoryBot.create(:admin_settings) throws an error. )


# The following lines were needed to get cucumber started,
# they have now been moved to features/support/env.rb.
# (Left here for legacy documentation??)
#
# puts "Loading default data set... "
# anon =  FactoryBot.generate :anonymous_user
# admin = FactoryBot.generate :admin_user
# device_config = FactoryBot.create(:device_config)
# Admin::Settings.create_or_update_default_settings_from_settings_yml
# puts "done."
