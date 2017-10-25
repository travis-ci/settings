require 'active_record'
require 'travis/encrypt/helpers/active_record'

module Settings
  module Record
    class EnvVar < ActiveRecord::Base
      include Travis::Encrypt::Helpers::ActiveRecord

      belongs_to :owner, polymorphic: true

      attr_encrypted :value

      def self.by_owner(owner)
        where(owner: owner)
      end

      def to_h
        { name => value }
      end
    end

    class SshKey < ActiveRecord::Base
      include Travis::Encrypt::Helpers::ActiveRecord

      belongs_to :owner, polymorphic: true

      attr_encrypted :key

      def self.by_owner(owner)
        where(owner: owner)
      end
    end

    class Setting < ActiveRecord::Base
      belongs_to :owner, polymorphic: true

      def key
        super&.to_sym
      end

      def attributes
        super.merge(key: key)
      end
    end
  end
end
