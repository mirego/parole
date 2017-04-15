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
      validate :ensure_valid_role_for_commentable, if: lambda { commentable.present? && commentable.commentable? }
      validate :ensure_valid_commentable
      validate :ensure_valid_commenter
      validates :commenter, presence: true
      validates :commentable, presence: true
      validates :comment, presence: true
    end

  protected

    # Update the commentable cache counter columns
    #
    # Look for a `<role>_comments_count` and a `comments_count` column
    # in the commentable model and the commenter model and update their value with the count.
    def update_cache_counters
      commenter_has_comments = commenter.respond_to?(:comments)

      # Role-specific counter
      role_method = :"#{self.role}_comments_count="
      commentable.send role_method, commentable.comments.where(role: self.role).count if commentable.respond_to?(role_method)
      commenter.send role_method, commenter.comments.where(role: self.role).count if commenter_has_comments && commenter.respond_to?(role_method)

      # Global counter
      total_method = :comments_count=
      commentable.send total_method, commentable.comments.count if commentable.respond_to?(total_method)
      commenter.send total_method, commenter.comments.count if commenter_has_comments && commenter.respond_to?(total_method)

      commentable.save(validate: false)
      commenter.save(validate: false)
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
      errors.add(:commentable, :invalid) unless commentable.respond_to?(:commentable?) && commentable.commentable?
    end

    # Make sure that the commenter record on is an instance of a commenter model.
    def ensure_valid_commenter
      errors.add(:commenter, :invalid) unless commenter.respond_to?(:commenter?) && commenter.commenter?
    end
  end
end
