class Theme
  attr_accessor :id, :name, :font, :colors, :visibility, :has_transparent_button, :background

  def initialize(id: nil, name:, font:, colors:, visibility: nil, has_transparent_button: nil, background: nil)
    raise ArgumentError.new("name must be a string") unless name.is_a?(String)
    raise ArgumentError.new("font must be a string of one of the allowed values") unless font.is_a?(String)
    raise ArgumentError.new("visibility must be private") unless visibility == 'private' || visibility.nil?
    @id = id
    @name = name
    @font = font
    @colors = colors
    @visibility = visibility
    @has_transparent_button = has_transparent_button
    @background = background
  end

  def self.default
    Theme.new(
        has_transparent_button: false,
        visibility: 'private'
    )
  end

  def self.full_example
    Theme.new(
        name: 'A new theme',
        colors: colors,
        font: 'Karla',
        has_transparent_button: true,
        background: Background.full_example
    )
  end

  def self.colors
    {
      question: '#FF5733',
      answer: '#C70039',
      button: '#900C3F',
      background: '#581845'
    }
  end

  def payload
    payload = {
      name: name,
      font: font,
      colors: colors
    }
    payload[:has_transparent_button] = has_transparent_button unless has_transparent_button.nil?
    payload[:visibility] = visibility unless visibility.nil?
    payload[:background] = background.payload unless background.nil?
    payload.to_json
  end

  def self.from_response(payload)
    background = payload[:background].nil? ? nil : Background.from_response(payload[:background])
    new(
      id: payload[:id],
      name: payload[:name],
      font: payload[:font],
      colors: payload[:colors],
      visibility: payload[:visibility],
      has_transparent_button: payload[:has_transparent_button],
      background: background
    )
  end

  def same?(actual)
    (id.nil? || id == actual.id) &&
      name == actual.name &&
      colors == actual.colors &&
      colors.keys == [:question, :answer, :button, :background] &&
      font == actual.font &&
      (visibility.nil? ? Theme.default.visibility : visibility) == actual.visibility &&
      (has_transparent_button.nil? ? Theme.default.has_transparent_button : has_transparent_button) == actual.has_transparent_button &&
      (background.nil? || background.same?(actual.background))
  end
end
