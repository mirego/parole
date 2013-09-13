require 'spec_helper'

describe Parole::Commentable do
  describe :comments do
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

  describe 'role comments' do
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

  describe 'cache counters' do
    before do
      spawn_comment_model
      spawn_commenter_model 'User'
      spawn_commentable_model 'Article' do
        acts_as_commentable roles: [:photos, :videos]
      end

      run_migration do
        create_table(:users, force: true)
        create_table(:articles, force: true) do |t|
          t.integer :photos_comments_count, default: 0
          t.integer :videos_comments_count, default: 0
          t.integer :comments_count, default: 0
        end
      end
    end

    let(:commenter) { User.create }
    let(:commentable) { Article.create }
    let(:create_comment!) { commentable.photos_comments.create(commenter: commenter, comment: 'Booya') }

    it { expect { create_comment! }.to change { commentable.reload.photos_comments_count }.from(0).to(1) }
    it { expect { create_comment! }.to_not change { commentable.reload.videos_comments_count } }
    it { expect { create_comment! }.to change { commentable.reload.comments_count }.from(0).to(1) }
  end
end
