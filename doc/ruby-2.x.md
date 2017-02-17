## Upgrading Portal to Ruby 2.x (2.2.0)

Rails 3.2.22 officially supports Ruby 2.2:
http://weblog.rubyonrails.org/2015/6/16/Rails-3-2-22-4-1-11-and-4-2-2-have-been-released-and-more/

Obviously `bundle install` fails.

A few gems need to be updated. Our own gems too, but I've commented them out for now.
I've also removed debugger and pry-debugger, as they seem to be bound to 1.9.3. Not sure 
devs use them (I use RubyMine debugger), but I guess we can install something similar.

Ruby 2.2 removed `YAML::ENGINE`, so I had to modify `config/environment.rb`. There're comments
and it feels safe to me.

### Issues:

#### HAML / SASS / Compass

It seems that `/gems/haml-e428066e86e1/lib/sass.rb`
tries to load `vendor/sass/lib/sass.rb` which is not present, as it's submodule.

```
unless Haml::Util.try_sass
  load Haml::Util.scope('vendor/sass/lib/sass.rb')
end
```

try_sass checks if Sass is loaded. For some reason, when Ruby 1.9.3 is used, this line is probably not executed.

Sass used to be part of HAML and our custom HAML gem is old enough to assume so.
However, we include bunch of newer sass gems and I guess this is causing some conflict.

It happens while using either Ruby 2.0 or 2.2.

When I tried to start server, I was asked to add `gem 'test-unit', '~> 3.0'` so I did it.

Quite often I could see SEGFAULT error coming from mysql2 gem. Minor version bump / drop and reinstall usually helps.

##### When I try to update HAML to 3.1.8 (< 4.0):

> /gems/compass-core-1.0.3/lib/compass/core/sass_extensions.rb:3:in `<top (required)>': It looks like you've got an incompatible version of Sass. This often happens when you have an old haml gem installed. Please upgrade Haml to v3.1 or above. (LoadError)

It should work and should be the safest option, but well, it does not.

##### When I try to update HAML to 4.0:

This version has breaking changes, something might fail. Although I can start rails server and at least basic features 
seem to work.

Also, it means that we no longer use `xml-mime-type-and-ie8-keycode-fix` branch of CC's HAML fork.
How important is this fix? If it's related to IE8 only, it feels okay to me to drop it.

