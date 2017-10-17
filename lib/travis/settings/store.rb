module Travis
  module Settings
    class Store < Struct.new(:attrs)
      def save
        attrs.each { |key, value| record.send(:"#{key}=", value) }
        record.save
      end

      def delete
        record.delete
      end

      private

        def record
          @record ||= Record::Setting.find_or_initialize_by(id: attrs[:id])
        end
    end
  end
end
