module RocketChat
  #
  # Rocket.Chat Role
  #
  class Role
    # Raw role data
    attr_reader :data

    #
    # @param [Hash] data Raw role data
    #
    def initialize(data)
      @data = Util.stringify_hash_keys data
    end

    # Role id
    def id
      data['_id']
    end

    # Role scope
    def scope
      data['scope']
    end

    # Role description
    def description
      data['description']
    end

    # Role protected
    def role_protected?
      data['protected']
    end

    def inspect
      format(
        '#<%<class_name>s:0x%<object_id>p @id="%<id>s" @scope="%<scope>s" @description="%<description>s" @protected="%<role_protected>s">',
        class_name: self.class.name,
        object_id: object_id,
        id: id,
        scope: scope,
        description: description,
        role_protected: role_protected?
      )
    end
  end
end
