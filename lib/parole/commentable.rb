module Parole
  module Commentable
    extend ActiveSupport::Concern

    included do
      # Default options for all comments associations
      association_options = { class_name: 'Comment', as: :commentable, dependent: :destroy }

      # All comments for the record
      has_many :comments, association_options

      # Role-specific comments for the record
      commentable_options.fetch(:roles).each do |role|
        has_many :"#{role}_comments", lambda { where(role: role) }, association_options
      end
    end
  end
end
