module Travis
  module Settings
    module Definition
      class Base < Struct.new(:opts)
        %i(type key scope inherit default min max requires).each do |key|
          define_method(key) { opts[key] }
        end

        %i(encrypted internal).each do |key|
          define_method(key) { !!opts[key] }
        end

        def keys
          [key] + self.alias
        end

        def alias
          Array(opts[:alias])
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
end
