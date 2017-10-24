require 'travis/settings/definition/collection'
require 'travis/settings/definition/setting'

module Travis
  module Settings
    module Definition
      OWNERS = {
        global: 'NilClass',
        owners: 'OwnerGroup',
        repo:   'Repository',
        org:    'Organization',
        user:   'User'
      }
    end
  end
end
