require 'spec_helper'

describe Parole::Commentable do
  describe 'general `comments` relation' do
    context 'without defined roles' do
      before do
        spawn_comment_model
        spawn_commentable_model 'Article'

        run_migration do
          create_table(:articles, force: true)
        end
      end

      it { expect(Article.create.comments).to be_instance_of(relation_class(Comment)) }
      it { expect(Article.create.comments.new.role).to be_blank }
    end

    context 'with roles' do
      before do
        spawn_comment_model
        spawn_commentable_model 'Article' do
          acts_as_commentable roles: [:photos, :videos]
        end

        run_migration do
          create_table(:articles, force: true)
        end
      end

      it { expect(Article.create.comments).to be_an_instance_of(relation_class(Comment)) }
      it { expect(Article.create.photos_comments).to be_an_instance_of(relation_class(Comment)) }
      it { expect(Article.create.videos_comments).to be_an_instance_of(relation_class(Comment)) }
      it { expect(Article.create.comments.new.role).to be_blank }
      it { expect(Article.create.photos_comments.new.role).to eql 'photos' }
      it { expect(Article.create.videos_comments.new.role).to eql 'videos' }
    end
  end
end
