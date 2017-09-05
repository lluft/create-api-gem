class Notifications
  attr_accessor :self_enabled, :self_recipients, :self_reply_to, :self_subject, :self_message,
                :respondent_enabled, :respondent_recipient, :respondent_reply_to, :respondent_subject, :respondent_message

  def initialize(self_enabled: nil, self_recipients: nil, self_reply_to: nil, self_subject: nil, self_message: nil,
                 respondent_enabled: nil, respondent_recipient: nil, respondent_reply_to: nil, respondent_subject: nil, respondent_message: nil)
    @self_enabled = self_enabled
    @self_recipients = self_recipients
    @self_reply_to = self_reply_to
    @self_subject = self_subject
    @self_message = self_message
    @respondent_enabled = respondent_enabled
    @respondent_recipient = respondent_recipient
    @respondent_reply_to = respondent_reply_to
    @respondent_subject = respondent_subject
    @respondent_message = respondent_message
  end

  def self.from_response(response)
    self_payload = response[:self]
    self_payload.keys.each do |key|
      new_key = 'self_' + key.to_s
      self_payload[new_key.to_sym] = self_payload.delete(key)
    end
    respondent_payload = response[:respondent]
    respondent_payload.keys.each do |key|
      new_key = 'respondent_' + key.to_s
      respondent_payload[new_key.to_sym] = respondent_payload.delete(key)
    end
    params = respondent_payload.merge(self_payload)
    Notifications.new(params)
  end

  def payload
    payload = {}
    unless self_recipients.nil? && self_subject.nil? && self_message.nil?
      payload[:self] = {}
      payload[:self][:enabled] = self_enabled unless self_enabled.nil?
      payload[:self][:reply_to] = self_reply_to unless self_reply_to.nil?
      payload[:self][:recipients] = self_recipients unless self_recipients.nil?
      payload[:self][:subject] = self_subject unless self_subject.nil?
      payload[:self][:message] = self_message unless self_message.nil?
    end
    unless respondent_recipient.nil? && respondent_subject.nil? && respondent_message.nil?
      payload[:respondent] = {}
      payload[:respondent][:enabled] = respondent_enabled unless respondent_enabled.nil?
      payload[:respondent][:reply_to] = respondent_reply_to unless respondent_reply_to.nil?
      payload[:respondent][:recipient] = respondent_recipient unless respondent_recipient.nil?
      payload[:respondent][:subject] = respondent_subject unless respondent_subject.nil?
      payload[:respondent][:message] = respondent_message unless respondent_message.nil?
    end
    payload
  end

  def same?(actual)
    (self_enabled.nil? || self_enabled == actual.self_enabled) &&
      (self_reply_to.nil? || self_reply_to == actual.self_reply_to) &&
      (self_recipients.nil? || self_recipients == actual.self_recipients) &&
      (self_subject.nil? || self_subject == actual.self_subject) &&
      (self_message.nil? || self_message == actual.self_message) &&
      (respondent_enabled.nil? || respondent_enabled == actual.respondent_enabled) &&
      (respondent_reply_to.nil? || respondent_reply_to == actual.respondent_reply_to) &&
      (respondent_recipient.nil? || respondent_recipient == actual.respondent_recipient) &&
      (respondent_subject.nil? || respondent_subject == actual.respondent_subject) &&
      (respondent_message.nil? || respondent_message == actual.respondent_message)
  end

  def self.full_example(email_block_for_notifications_ref)
    Notifications.new(self_enabled: false, self_reply_to: '{{field:' + email_block_for_notifications_ref + '}}', self_recipients: ['recipient1@email.com', 'recipient2@email.com'],
                      self_subject: 'An email subject', self_message: 'This is a message that will be in an email',
                      respondent_enabled: true, respondent_reply_to: ['hello@email.com'], respondent_recipient: '{{field:' + email_block_for_notifications_ref + '}}',
                      respondent_subject: 'An email subject', respondent_message: 'This is a message that will be in an email')
  end
end