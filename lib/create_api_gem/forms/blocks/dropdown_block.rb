class DropdownBlock < Block
  attr_accessor :id, :title, :type, :ref, :description, :alphabetical_order, :choices, :required, :attachment

  def initialize(id: nil, title:, type: :dropdown, ref: nil, description: nil, alphabetical_order: nil,
                 choices:, required: nil, attachment: nil)
    super
    raise ArgumentError.new("at least two choices must be sent") unless choices.length >= 2
    @id = id
    @title = title
    @type = type
    @ref = ref
    @description = description
    @alphabetical_order = alphabetical_order
    @choices = choices
    @required = required
    @attachment = attachment
  end

  def self.choices
      [
          {label: 'choice 1'},
          {label: 'choice 2'}
      ]
  end

  def payload
    payload = {}
    payload[:properties] = {}
    payload[:title] = title
    payload[:type] = type.to_s
    payload[:ref] = ref unless ref.nil?
    payload[:id] = id unless id.nil?
    payload[:properties][:choices] = choices
    payload[:properties][:description] = description unless description.nil?
    payload[:properties][:alphabetical_order] = alphabetical_order unless alphabetical_order.nil?
    unless required.nil?
      payload[:validations] = {}
      payload[:validations][:required] = required
    end
    payload[:attachment] = attachment unless attachment.nil?
    payload
  end

  def same_extra_attributes?(actual)
    same_choices?(actual.choices) &&
      (alphabetical_order.nil? ? DropdownBlock.default.alphabetical_order : alphabetical_order) == actual.alphabetical_order &&
      (required.nil? ? DropdownBlock.default.required : required) == actual.required &&
      (attachment.nil? || attachment == actual.attachment)
  end

  def same_choices?(actual_choices)
    choices.zip(actual_choices).all? do |expected, actual|
      (!expected.key?(:id) || expected[id] == actual[id]) &&
        expected[:label] == actual[:label]
    end
  end

  def self.default
    DropdownBlock.new(
        title: 'A dropdown block',
        choices: choices,
        alphabetical_order: false,
        required: false
    )
  end

  def self.full_example(id: nil)
    DropdownBlock.new(
        title: 'A dropdown block',
        ref: Block.ref,
        description: 'a description of the dropdown block',
        id: id,
        choices: choices,
        alphabetical_order: true,
        required: true,
        attachment: Block.attachment
    )
  end
end