module Parole
  module Comment
    extend ActiveSupport::Concern

    included do
      # Associations
      belongs_to :commentable, polymorphic: true
      belongs_to :commenter, polymorphic: true

      # Callbacks
      after_create :update_cache_counters
      after_destroy :update_cache_counters

      # Validations
      validate :ensure_valid_role_for_commentable
      validate :ensure_valid_commentable
      validate :commenter, presence: true
      validate :commentable, presence: true
      validate :comment, presence: true
    end

  protected

    # Update the commentable cache counter columns
    #
    # Look for a `<role>_comments_count` and a `comments_count` column
    # in the commentable model and update their value with the count.
    def update_cache_counters
      role_method = :"#{self.role}_comments_count="
      if commentable.respond_to?(role_method)
        commentable.send role_method, commentable.comments.where(role: self.role).count
      end

      total_method = :comments_count=
      if commentable.respond_to?(total_method)
        commentable.send total_method, commentable.comments.count
      end

      commentable.save(validate: false)
    end

    # Make sure that the value of the `role` attribute is a valid role
    # for the commentable.
    #
    # If the commentable doesn't have any comment roles, we make sure
    # that the value is blank.
    def ensure_valid_role_for_commentable
      return false unless commentable.present?
      
      allowed_roles = commentable.class.commentable_options[:roles]

      if allowed_roles.any?
        errors.add(:role, :invalid) unless allowed_roles.include?(self.role)
      else
        errors.add(:role, :invalid) unless self.role.blank?
      end
    end

    # Make sure that the record we're commenting on is an instance
    # of a commentable model.
    def ensure_valid_commentable
      klass = commentable.class
      errors.add(:commentable, :invalid) unless klass.respond_to?(:acts_as_commentable?) && klass.acts_as_commentable?
    end
  end
end
