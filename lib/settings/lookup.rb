require 'settings/factory/collection'
require 'settings/factory/setting'

module Settings
  class Lookup < Struct.new(:group, :definitions, :owner)
    def run
      settings.map { |setting| [setting.key, setting] }.to_h
    end

    private

      def settings
        definitions.map { |definition| instance_for(definition) }
      end

      def instance_for(definition)
        const = definition.type == :collection ? Factory::Collection : Factory::Setting
        records = records_for(definition.key)
        const.new(definition, group, owner, records).instance
      end

      def records_for(key)
        records.select { |record| record.key == key }
      end

      def records
        @records ||= Record::Setting.where(key: keys, owner: owner).order(:id).all
      end

      def keys
        definitions.map(&:keys).flatten
      end

      # TODO this would allow using nested keys for collections. e.g. values
      # on the collection :foo could have keys like foo.one and foo.other.  i
      # think that might be useful for clients, but it also might be just
      # yagni. discuss this with others.

      # def keys
      #   keys = definitions.map(&:key)
      #   strs = keys.zip(keys.map { |key| "#{key}.%" }).flatten
      #   cond = Array.new(keys.size) { 'key = ? OR key LIKE ?' }.join(' OR ')
      #   ["(#{cond})", *strs]
      # end
      #
      # def matches?(one, other)
      #   one == other or other.to_s.start_with?("#{one}.")
      # end
  end
end
