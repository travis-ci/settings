module Settings
  class Store < Struct.new(:attrs)
    class ActiveRecord < Struct.new(:attrs)
      def save
        record = Record::Setting.find_or_initialize_by(id: attrs[:id])
        record.update_attributes!(attrs)
        record.id
      end

      def delete
        Record::Setting.where(id: attrs[:id]).delete_all
      end
    end

    class Sequel < Struct.new(:attrs)
      def save
        raise 'implement'
      end

      def delete
        raise 'implement'
      end
    end

    def save
      adapter.save
    end

    def delete
      adapter.delete
    end

    private

      def adapter
        const = defined?(::Sequel) ? Sequel : ActiveRecord
        const.new(attrs)
      end
  end
end
