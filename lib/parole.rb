require 'parole/version'

require 'active_record'
require 'active_support'

require 'parole/commentable'
require 'parole/comment'

class ActiveRecord::Base
  def self.acts_as_commentable(options = {})
    Parole.commentable_classes << self

    class_attribute :commentable_options, :actually_acts_as_commentable
    self.actually_acts_as_commentable = true
    self.commentable_options = options.reverse_merge(roles: [])
    self.commentable_options[:roles] = commentable_options[:roles].map(&:to_s)

    include Parole::Commentable
  end

  def self.acts_as_commentable?
    self.respond_to?(:actually_acts_as_commentable) && self.actually_acts_as_commentable
  end

  def self.acts_as_comment(*args)
    include Parole::Comment
  end

  def commentable?
    self.class.acts_as_commentable?
  end
end

module Parole
  def self.commentable_classes
    @commentable_classes ||= []
  end
end
