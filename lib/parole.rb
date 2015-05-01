require 'parole/version'

require 'active_record'
require 'active_support'

require 'parole/commentable'
require 'parole/commenter'
require 'parole/comment'

class ActiveRecord::Base
  def self.acts_as_commentable(options = {})
    class_attribute :commentable_options, :actually_acts_as_commentable
    self.actually_acts_as_commentable = true

    self.commentable_options = options.reverse_merge(roles: [])
    self.commentable_options[:roles] = commentable_options[:roles].map(&:to_s)

    include Parole::Commentable
  end

  def self.acts_as_commenter(options = {})
    class_attribute :actually_acts_as_commenter
    self.actually_acts_as_commenter = true

    include Parole::Commenter
  end

  def self.acts_as_commentable?
    self.respond_to?(:actually_acts_as_commentable) && self.actually_acts_as_commentable
  end

  def self.acts_as_commenter?
    self.respond_to?(:actually_acts_as_commenter) && self.actually_acts_as_commenter
  end

  def self.acts_as_comment(*args)
    include Parole::Comment
  end

  def commentable?
    self.class.acts_as_commentable?
  end

  def commenter?
    self.class.acts_as_commenter?
  end
end
