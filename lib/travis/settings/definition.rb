module Travis
  module Settings
    class Definition < Struct.new(:attrs)
      OWNERS = {
        global: 'NilClass',
        owners: 'OwnerGroup',
        repo:   'Repository',
        org:    'Organization',
        user:   'User'
      }

      %i(type key scope inherit default min max requires).each do |key|
        define_method(key) { attrs[key] }
      end

      def internal
        !!attrs[:internal]
      end

      def owner?(owner)
        attrs[:owner].any? { |key| OWNERS[key] == owner.class.name }
      end

      def owner_key(name)
        OWNERS.invert[name]
      end
    end
  end
end
