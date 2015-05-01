require 'spec_helper'

describe Parole::Comment do
  describe :Validations do
    before do
      spawn_comment_model
      spawn_commenter_model 'User'
      spawn_commentable_model 'Article'

      run_migration do
        create_table(:users, force: true)
        create_table(:articles, force: true)
      end
    end

    let(:errors) do
      subject.valid?
      subject.errors.full_messages
    end

    describe :validates_comment do
      subject { Comment.new }
      it { expect(errors).to include("Comment can't be blank") }
    end

    describe :validates_commenter_presence do
      subject { Comment.new }
      it { expect(errors).to include("Commenter can't be blank") }
    end

    describe :validates_commentable_presence do
      subject { Comment.new }
      it { expect(errors).to include("Commentable can't be blank") }
    end

    describe :validates_commentable do
      subject { Comment.new(commentable: User.new) }
      it { expect(errors).to include("Commentable is invalid") }
    end
  end

  describe :ClassMethods do
    describe :create do
      context 'through general `comments` association' do
        before do
          spawn_comment_model
          spawn_commenter_model 'User'
          spawn_commentable_model 'Article'

          run_migration do
            create_table(:articles, force: true)
            create_table(:users, force: true)
          end
        end

        let(:commenter) { User.create }
        let(:commentable) { Article.create }

        context 'without role attribute' do
          let(:comment) { commentable.comments.create(commenter: commenter, comment: 'Booya') }

          it { expect(comment).to be_persisted }
          it { expect(comment.comment).to eql 'Booya' }
          it { expect(comment.commenter).to eql commenter }
          it { expect(comment.commentable).to eql commentable }
        end

        context 'with role attribute' do
          let(:comment) { commentable.comments.create(role: 'YEP', commenter: commenter, comment: 'Booya') }
          it { expect(comment).to_not be_persisted }
          it { expect(comment.errors.full_messages).to eql ['Role is invalid'] }
        end
      end

      context 'through a role-specific comments association' do
        before do
          spawn_comment_model
          spawn_commenter_model 'User'
          spawn_commentable_model 'Article' do
            acts_as_commentable roles: [:photos, :videos]
          end

          run_migration do
            create_table(:articles, force: true)
            create_table(:users, force: true)
          end
        end

        let(:commenter) { User.create }
        let(:commentable) { Article.create }

        context 'with commentable role association method' do
          let(:comment) { commentable.photos_comments.create(commenter: commenter, comment: 'Booya') }

          it { expect(comment).to be_persisted }
          it { expect(comment.role).to eql 'photos' }
          it { expect(comment.comment).to eql 'Booya' }
          it { expect(comment.commenter).to eql commenter }
          it { expect(comment.commentable).to eql commentable }
        end

        context 'with commentable main association method' do
          context 'with valid role' do
            let(:comment) { commentable.comments.create(role: 'photos', commenter: commenter, comment: 'Booya') }

            it { expect(comment).to be_persisted }
            it { expect(comment.role).to eql 'photos' }
            it { expect(comment.comment).to eql 'Booya' }
            it { expect(comment.commenter).to eql commenter }
            it { expect(comment.commentable).to eql commentable }
          end

          context 'with invalid role' do
            let(:comment) { commentable.comments.create(role: 'NOPE', commenter: commenter, comment: 'Booya') }
            it { expect(comment).to_not be_persisted }
            it { expect(comment.errors.full_messages).to eql ['Role is invalid'] }
          end
        end
      end
    end
  end

  describe :InstanceMethods do
    describe :update_cache_counters do
      before do
        spawn_comment_model
        spawn_commenter_model 'User'
        spawn_commentable_model 'Article' do
          acts_as_commentable roles: [:photos, :videos]
        end

        run_migration do
          create_table(:users, force: true) do |t|
            t.integer :photos_comments_count, default: 0
            t.integer :videos_comments_count, default: 0
            t.integer :comments_count, default: 0
          end
          create_table(:articles, force: true) do |t|
            t.integer :photos_comments_count, default: 0
            t.integer :videos_comments_count, default: 0
            t.integer :comments_count, default: 0
          end
        end
      end

      let(:commenter) { User.create }
      let(:commentable) { Article.create }
      let(:create_comment!) { commentable.photos_comments.create!(commenter: commenter, comment: 'Booya') }

      # Commentable cache counter
      it { expect { create_comment! }.to change { commentable.reload.photos_comments_count }.from(0).to(1) }
      it { expect { create_comment! }.to_not change { commentable.reload.videos_comments_count } }
      it { expect { create_comment! }.to change { commentable.reload.comments_count }.from(0).to(1) }

      # Commenter cache counter
      it { expect { create_comment! }.to change { commenter.reload.photos_comments_count }.from(0).to(1) }
      it { expect { create_comment! }.to_not change { commenter.reload.videos_comments_count } }
      it { expect { create_comment! }.to change { commenter.reload.comments_count }.from(0).to(1) }
    end
  end

  describe :ensure_valid_role_for_commentable do
    before do
      spawn_comment_model
      spawn_commenter_model 'User'

      run_migration do
        create_table(:users, force: true)
      end
    end

    let(:commenter) { User.create }

    context 'without associated commentable' do
      let(:comment) { Comment.new(commenter: commenter, comment: 'Booya') }

      it { expect { comment.valid? }.to_not raise_error }
    end
  end
end
