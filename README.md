<p align="center">
  <a href="https://github.com/mirego/parole">
    <img src="http://i.imgur.com/QQlNfGL.png" alt="Parole" />
  </a>
  <br />
  Parole adds the ability to comment on ActiveRecord records.
  <br /><br />
  <a href="https://rubygems.org/gems/parole"><img src="https://badge.fury.io/rb/parole.png" /></a>
  <a href="https://codeclimate.com/github/mirego/parole"><img src="https://codeclimate.com/github/mirego/parole.png" /></a>
  <a href="https://travis-ci.org/mirego/parole"><img src="https://travis-ci.org/mirego/parole.png?branch=master" /></a>
</p>

---

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'parole'
```

Then run the task to generate the migration:

```bash
$ rails generate parole:install
```

## Usage

You should now be able to mark models as *commentable*:

```ruby
class Article < ActiveRecord::Base
  acts_as_commentable
end
```

You’re pretty much done after that. You’re now able to do this:

```ruby
user = User.find(1)
article = Article.find(1)

article.comments.create(commenter: user, comment: 'Hello world!')
article.comments.count # => 1
```

You can also provide roles for comments, so you can have multiple type of comments per record.

```ruby
class Article < ActiveRecord::Base
  acts_as_commentable roles: [:photos, :videos]
end

user = User.find(1)
article = Article.find(1)

article.photos_comments.create(commenter: user, comment: 'Hello world!')
article.photos_comments.count # => 1
article.comments.count # => 1
```

### Cache counters

Whenever a comment is created or destroyed, Parole looks into the commentable record and check
if there’s a `<role>_comments_count` column and/or a `comments_count` column. If so, it updates
them so they reflect the total number of comments and the number of comments of this role for
the record.

So let’s say the `Article` model has the following columns: `photos_comments_count`, `videos_comments_count` and `comments_count`.

```ruby
class Article < ActiveRecord::Base
  acts_as_commentable roles: [:photos, :videos]
end

user = User.find(1)
article = Article.find(1)

article.photos_comments.create(commenter: user, comment: 'Hello world!')
article.photos_comments_count # => 1
article.videos_comments_count # => 0
article.comments_count # => 1

article.videos_comments.create(commenter: user, comment: 'Hello world again!')
article.photos_comments_count # => 1
article.videos_comments_count # => 1
article.comments_count # => 2
```

## License

`Parole` is © 2013-2015 [Mirego](http://www.mirego.com) and may be freely distributed under the [New BSD license](http://opensource.org/licenses/BSD-3-Clause).  See the [`LICENSE.md`](https://github.com/mirego/parole/blob/master/LICENSE.md) file.

## About Mirego

[Mirego](http://mirego.com) is a team of passionate people who believe that work is a place where you can innovate and have fun. We're a team of [talented people](http://life.mirego.com) who imagine and build beautiful Web and mobile applications. We come together to share ideas and [change the world](http://mirego.org).

We also [love open-source software](http://open.mirego.com) and we try to give back to the community as much as we can.
