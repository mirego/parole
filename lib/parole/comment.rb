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

    def ensure_valid_role_for_commentable
      allowed_roles = commentable.class.commentable_options[:roles]

      if allowed_roles.any?
        errors.add(:role, :invalid) unless allowed_roles.include?(self.role)
      else
        errors.add(:role, :invalid) unless self.role.blank?
      end
    end

    def ensure_valid_commentable
      klass = commentable.class
      errors.add(:commentable, :invalid) unless klass.respond_to?(:acts_as_commentable?) && klass.acts_as_commentable?
    end
  end
end
