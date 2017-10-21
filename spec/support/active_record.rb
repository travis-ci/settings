require 'active_record'

ActiveRecord::Base.establish_connection(adapter: :postgresql, database: 'settings')
ActiveRecord::Base.default_timezone = :utc

User = Class.new(ActiveRecord::Base)
Organization = Class.new(ActiveRecord::Base)
OwnerGroup = Class.new(ActiveRecord::Base)

class Repository < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  def owners
    OwnerGroup.where(owner_id: owner_id, owner_type: owner_type).first
  end
end
