class Block
  def initialize(*args)
    block = args.first
    raise ArgumentError.new("title must be a string") unless block[:title].is_a?(String)
    raise ArgumentError.new("ref must be a string") unless block[:ref].is_a?(String) || block[:ref].nil?
  end

  def self.all_types
    {
      'date block' => DateBlock,
      'dropdown block' => DropdownBlock,
      'email block' => EmailBlock,
      'file upload block' => FileUploadBlock,
      'group block' => GroupBlock,
      'legal block' => LegalBlock,
      'long text block' => LongTextBlock,
      'multiple choice block' => MultipleChoiceBlock,
      'number block' => NumberBlock,
      'opinion scale block' => OpinionScaleBlock,
      'payment block' => PaymentBlock,
      'picture choice block' => PictureChoiceBlock,
      'rating block' => RatingBlock,
      'short text block' => ShortTextBlock,
      'statement block' => StatementBlock,
      'website block' => WebsiteBlock,
      'yes no block' => YesNoBlock
    }
  end

  def self.from_response(response)
    response[:type] = response[:type].to_sym
    if response[:type] == :group
      response[:properties][:fields].map! { |field| Block.from_response(field) } unless response[:properties][:fields].nil?
    end
    properties = response[:properties] || {}
    validations = response[:validations] || {}
    block_params = response.keep_if { |k, _| k != :properties && k != :validations } || {}
    params = properties.merge(validations).merge(block_params)
    all_types.fetch(block_symbol_to_string(response[:type])).new(params)
  end

  def same?(actual)
    (id.nil? || id == actual.id) &&
      type == actual.type &&
      title == actual.title &&
      (ref.nil? || ref == actual.ref) &&
      (description.nil? || description == actual.description) &&
      (respond_to?(:attachment) ? same_attachment?(actual.attachment) : true) &&
      same_extra_attributes?(actual)
  end

  def same_attachment?(actual_attachment)
    return true if attachment.nil?
    type = attachment[:type]
    case type
    when 'image'
      return (attachment[:href].start_with?("#{APIConfig.clafoutis_address}/images/") && actual_attachment[:href].start_with?("#{APIConfig.clafoutis_address}/images/"))
    when 'video'
      return attachment == actual_attachment
    else
      return false
    end
  end

  def self.ref
     (0...8).map { (65 + rand(26)).chr }.join
  end

  def self.attachment
    [Block.image_attachment_payload, Block.video_attachment_payload].sample
  end

  def self.image_attachment_payload(image_id: 'default')
    raise ArgumentError.new("image_id must be a string of 12 characters") unless (image_id.is_a?(String) && image_id.length == 12 || image_id == 'default')
    { type: 'image', href: "#{APIConfig.clafoutis_address}/images/#{image_id}" }
  end

  def self.video_attachment_payload(video_url: 'https://www.youtube.com/watch?v=Uui3oT-XBxs', scale: 0.6)
    raise ArgumentError.new("scale must be one of these values [0.4, 0.6, 0.8, 1]") unless [0.4, 0.6, 0.8, 1].include?(scale) && !scale.nil?
    raise ArgumentError.new("video_url must be either a vimeo or youtube link") unless (video_url.include?('youtube') || video_url.include?('vimeo'))
    { type: 'video', href: video_url, scale: scale }
  end

  private

  def self.block_symbol_to_string(symbol)
    string = symbol.to_s
    string.sub!('_', ' ')
    string + ' block'
  end

end