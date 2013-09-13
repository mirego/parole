module Parole
  module Commentable
    extend ActiveSupport::Concern

    included do
      # Default options for all comments associations
      association_options = { polymorphic: true, class_name: 'Comment', as: :commentable, dependent: :destroy }

      # All comments for the record
      has_many :comments, association_options

      # Role-specific comments for the record
      commentable_options.fetch(:roles).each do |role|
        options = association_options.merge before_add: lambda { |_, comment| comment.role = role }
        has_many :"#{role}_comments", lambda { where(role: role) }, options
      end
    end
  end
end
