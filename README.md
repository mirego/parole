# Parole

[![Gem Version](https://badge.fury.io/rb/parole.png)](https://rubygems.org/gems/parole)
[![Code Climate](https://codeclimate.com/github/mirego/parole.png)](https://codeclimate.com/github/mirego/parole)
[![Build Status](https://travis-ci.org/mirego/parole.png?branch=master)](https://travis-ci.org/mirego/parole)

Parole adds the ability to comment on ActiveRecord records.

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

`Parole` is © 2013 [Mirego](http://www.mirego.com) and may be freely distributed under the [New BSD license](http://opensource.org/licenses/BSD-3-Clause).  See the [`LICENSE.md`](https://github.com/mirego/parole/blob/master/LICENSE.md) file.

## About Mirego

Mirego is a team of passionate people who believe that work is a place where you can innovate and have fun. We proudly build mobile applications for [iPhone](http://mirego.com/en/iphone-app-development/ "iPhone application development"), [iPad](http://mirego.com/en/ipad-app-development/ "iPad application development"), [Android](http://mirego.com/en/android-app-development/ "Android application development"), [Blackberry](http://mirego.com/en/blackberry-app-development/ "Blackberry application development"), [Windows Phone](http://mirego.com/en/windows-phone-app-development/ "Windows Phone application development") and [Windows 8](http://mirego.com/en/windows-8-app-development/ "Windows 8 application development") in beautiful Quebec City.

We also love [open-source software](http://open.mirego.com/) and we try to extract as much code as possible from our projects to give back to the community.
