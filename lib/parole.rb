require 'parole/version'

require 'active_record'
require 'active_support'

require 'parole/commentable'
require 'parole/comment'

class ActiveRecord::Base
  def self.acts_as_commentable(options = {})
    class_attribute :commentable_options
    self.commentable_options = options.reverse_merge(roles: [])
    self.commentable_options[:roles] = commentable_options[:roles].map(&:to_s)

    include Parole::Commentable
  end

  def self.acts_as_comment(*args)
    include Parole::Comment
  end
end
