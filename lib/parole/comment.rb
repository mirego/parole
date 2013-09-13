module Parole
  module Comment
    extend ActiveSupport::Concern

    included do
      belongs_to :commentable, polymorphic: true
      belongs_to :commenter, polymorphic: true

      after_create :update_cache_counters
      after_destroy :update_cache_counters
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
  end
end
