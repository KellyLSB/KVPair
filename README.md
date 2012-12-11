# KVPair

KVPair is a Key Value Pair engine for Rails 3.1 if your using 3.2+ ActiveRecord has it's own Key Value Store solution as described in the release notes [here](http://guides.rubyonrails.org/3_2_release_notes.html#active-record)

## Installing KVPair

You can install KVPair with [RubyGems](https://rubygems.org/gems/kvpair).

`gem install kvpair` or `gem 'kvpair'`

Add the following code to a migration (will add generator later)

```ruby
# Key value pair table
create_table :kvpairs do |t|
    t.string :owner
    t.string :namespace
    t.string :key
    t.string :value
end

# Indexes
add_index :kvpairs, :key
add_index :kvpairs, :owner
add_index :kvpairs, :namespace
```

Add the following to `app/models/kvpair.rb`

```ruby
class Kvpair < ActiveRecord::Base
end
```

## Documentation for KVPair

Add to any model by like this

```ruby
class User < ActiveRecord::Base
    kvpair :social_networks
end
```

And use like this

```ruby
# Retrieve
user = User.find(1)
user.social_networks[:twitter]
# => 'KellyLSB'

# Save
user.social_networks = {
    :twitter => 'KellyLSB',
    :github => 'KellyLSB'
}
```

## Contributing to KVPair
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Kelly Becker. See LICENSE.txt for
further details.

