This repository exists to discuss https://github.com/travis-pro/team-teal/issues/1831

# Querying

```ruby
class Settings < Travis::Settings::Group
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

settings = Settings.new(user, config)

settings.all                 # all settings, except interal ones
settings.all(:beta)          # all settings for the scope :beta, except internal ones
settings.all(internal: true) # all internal settings
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
class Settings < Travis::Settings::Group
  # given as a value
  int :timeout, default: 5

  # given as a key for another setting
  int :timeout, default: :other_setting

  # given as a proc (will be passed the group instance)
  int :timeout, default: ->(s) { s.config[:timeout] || 60 * 60 }
end
```

# Inheritance

```ruby
class Settings < Travis::Settings::Group
  int :timeout,
    owner: [:owners, :user, :org, :repo],
    inherit: [:owner, :owners],
    default: 5
end

# assuming repo.owner == user, and repo.owners == owners
repo_setting = Settings.new(repo)[:timeout]
repo_setting.value # => 5

owners_setting = Settings.new(owners)[:timeout]
owners_setting.set(10)
repo_setting.value # => 10

user_setting = Settings.new(user)[:timeout]
user_setting.set(20)
repo_setting.value # => 20
```

# Value ranges

```ruby
class Settings < Travis::Settings::Group
  int :by_queue,
    owner: [:owners],
    scope: :repo,
    min: 0, # default
    max: 10,
    default: 5
end

setting = Settings.new(repo)[:by_queue]
setting.set(10)
setting.value   # => 10
setting.set(-1) # => raises an InvalidValue exception
setting.set(99) # => raises an InvalidValue exception

class Settings < Travis::Settings::Group
  # given as a value
  int :by_queue, max: 10

  # given as a key for another setting
  int :by_queue, max: :by_queue_max

  # given as a proc (will be passed the group instance)
  int :by_queue, max: ->(s) { s.config[:by_queue_max] || 10 }
end
```
