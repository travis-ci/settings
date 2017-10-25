This is a work in progress, and put here so we can discuss/review things.

I have chosen to not namespace `Settings` as `Travis::Settings` because this
one is taken by [travis-settings](https://github.com/travis-ci/travis-settings)
and it might be useful to be able to use both libraries in parallel for the
time being. We can namespace this library here, and deprecate `travis-settings`
once we've moved all apps over to the implementation here.

# Querying

```ruby
module App
  class Settings < ::Settings::Group
    bool :comic_sans,
      scope: :beta,
      owner: [:user],
      default: false

    int :by_queue_max,
      owner: [:owners],
      scope: :repo,
      internal: true,
      requires: :by_queue_enabled,
      default: 5

    bool :by_queue_enabled,
      owner: [:owners],
      scope: :repo,
      internal: true
  end
end

settings = App::Settings.new(user, config)

settings.all                 # all settings, except interal ones
settings.all(:beta)          # all settings for the scope :beta, except internal ones
settings.all(internal: true) # all internal settings

# Queries will only return settings that match the owner. E.g. settings for a
# user will only include settings that have `:user` specified as an allowed
# owner:

settings = App::Settings.new(user, config)
settings.all.map(&:key)
# => [:comic_sans]

settings = App::Settings.new(owners, config)
settings.all.map(&:key)
# => []

settings.all(internal: true).map(&:key)
# => [:by_queue_max, :by_queue_enabled]

```

# Serialization

```ruby
settings[:comic_sans].to_h
# =>
# {
#   scope: :beta_features,
#   key: :comic_sans,
#   owner_id: 1,
#   owner_type: 'User',
#   value: false,
#   type: :bool,
#   source: :default
# }
```

# Manipulation

```ruby
setting = settings[:comic_sans]
setting.enable
setting.enabled? # => true
setting.disable
setting.enabled? # => false

setting = settings[:by_queue_max]
setting.value    # => 5 (default)
setting.set(10)  # raises an InactiveSetting exception

settings[:by_queue_enabled].enable
setting.set(10)
setting.value    # => 10
```

# Defaults

```ruby
module App
  class Settings < ::Settings::Group
    # given as a value
    int :timeout, default: 5

    # given as a key for another setting
    int :timeout, default: :other_setting

    # given as a proc (will be passed the group instance)
    int :timeout, default: ->(s) { s.config[:timeout] || 60 * 60 }
  end
end
```

# Inheritance

```ruby
module App
  class Settings < ::Settings::Group
    int :timeout,
      owner: [:owners, :user, :org, :repo],
      inherit: [:owner, :owners],
      default: 5
  end
end

# assuming repo.owner == user, and repo.owners == owners
repo_setting = App::Settings.new(repo)[:timeout]
repo_setting.value # => 5

owners_setting = App::Settings.new(owners)[:timeout]
owners_setting.set(10)
repo_setting.value # => 10

user_setting = App::Settings.new(user)[:timeout]
user_setting.set(20)
repo_setting.value # => 20
```

# Value ranges

```ruby
module App
  class Settings < ::Settings::Group
    int :by_queue,
      owner: [:owners],
      scope: :repo,
      min: 0, # default
      max: 10,
      default: 5
  end
end

setting = App::Settings.new(repo)[:by_queue]
setting.set(10)
setting.value   # => 10
setting.set(-1) # => raises an InvalidValue exception
setting.set(99) # => raises an InvalidValue exception

module App
  class Settings < ::Settings::Group
    # given as a value
    int :by_queue, max: 10

    # given as a key for another setting
    int :by_queue, max: :by_queue_max

    # given as a proc (will be passed the group instance)
    int :by_queue, max: ->(s) { s.config[:by_queue_max] || 10 }
  end
end
```
