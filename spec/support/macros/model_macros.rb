module ModelMacros
  # Create a new commentable model
  def spawn_commentable_model(klass_name = 'Article', &block)
    spawn_model klass_name, ActiveRecord::Base do
      acts_as_commentable
      instance_exec(&block) if block
    end
  end

  # Create a new comment model
  def spawn_comment_model(klass_name = 'Comment', &block)
    spawn_model klass_name, ActiveRecord::Base do
      acts_as_comment
      instance_exec(&block) if block
    end
  end

  # Create a new commenter model
  def spawn_commenter_model(klass_name = 'User', &block)
    spawn_model klass_name, ActiveRecord::Base do
      has_many :comments
      instance_exec(&block) if block
    end
  end

  protected

  # Create a new model class
  def spawn_model(klass_name, parent_klass, &block)
    @spawned_models ||= []
    Object.instance_eval { remove_const klass_name } if Object.const_defined?(klass_name)
    @spawned_models << Object.const_set(klass_name, Class.new(parent_klass))
    Object.const_get(klass_name).class_eval(&block) if block_given?
  end

  def flush_models!
    @spawned_models.each { |model| Object.instance_eval { remove_const model.name.to_sym } }
  end
end
