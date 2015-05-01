module Parole
  module Commenter
    extend ActiveSupport::Concern

    included do
      # Default options for all comments associations
      association_options = { class_name: 'Comment', as: :commenter, dependent: :destroy }

      # All comments for the record
      has_many :comments, association_options

      # Role-specific comments for the record
      # TODO: We need to find a way to register global roles, because roles
      # are currently bound to commentable models
    end
  end
end
