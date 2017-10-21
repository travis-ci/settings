module Travis
  module Settings
    class Definition < Struct.new(:opts)
      OWNERS = {
        global: 'NilClass',
        owners: 'OwnerGroup',
        repo:   'Repository',
        org:    'Organization',
        user:   'User'
      }

      %i(type key scope inherit default min max requires).each do |key|
        define_method(key) { opts[key] }
      end

      %i(encrypted internal).each do |key|
        define_method(key) { !!opts[key] }
      end

      def owner?(owner)
        opts[:owner].any? { |key| OWNERS[key] == owner.class.name }
      end

      def owner_key(name)
        OWNERS.invert[name]
      end
    end
  end
end
