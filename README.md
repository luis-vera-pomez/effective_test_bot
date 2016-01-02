# Effective TestBot

Stop testing and start test botting.

A minitest library of capybara-webkit based feature tests that should pass in every Ruby on Rails application.

Adds many additional minitest assertions and capybara quality of life helper functions.

Provides a curated set of minitest/capybara/rails testing gems and a well configured `test_helper.rb` minitest file.

Includes a rake task to validate your testing environment.

Ensures that all fixtures and seeds are properly initialized.  Makes sure database transactions and web sessions correctly reset between tests.

Provides a DSL of class and instance level 1-liners that run entire test suites, checking many assertions all at once.

Autosaves an animated gif for any failing test.

Run `rake test:bot` to automatically check every route in your application against an appropriate test suite, without writing any code.

Automatically fills forms with appropriate pseudo-random input, and checks for all kinds of errors and omissions along the way.

Turn on tour mode to automatically generate animated gifs of every part of your website.

Makes sure everything actually works.

## Getting Started

First, make sure your site is using [devise](https://github.com/plataformatec/devise) and that your application javascript includes [jQuery](http://jquery.com/) and rails' [jquery_ujs](https://github.com/rails/jquery-ujs).

```ruby
gem 'devise'
gem 'jquery-rails'
```

and in your application.js file:

```ruby
//= require jquery
//= require jquery_ujs
```

Then you're ready to install `effective_test_bot`:

```ruby
group :test do
  gem 'effective_test_bot'
end
```

Run the bundle command to install it:

```console
bundle install
```

Install the configuration file:

```console
rails generate effective_test_bot:install
```

The generator will run `minitest:install` if minitest is not already present and create an initializer file which describes all configuration options.

Fixture or seed one user:

effective_test_bot requires that at least one user -- ideally a fully priviledged admin type user -- be available in the testing environment.

* There are future plans to make this better.  Right now `rake test:bot` just runs everything as one user.  There really isn't support for 'this user should not be able to'. yet.

As per the `test/test_helper.rb` default file, when minitest and/or effective_test_bot starts, following tasks are run:

```ruby
# Rails default task, load fixtures from test/fixtures/*.yml (including users.yml if it exists)
rake db:fixtures:load

# Rails default task, loads db/seeds.rb
rake db:seed

# Added by effective_test_bot.  loads test/fixtures/seeds.rb. 'cause screw yaml.
rake test:load_fixture_seeds
```

Your initial user may be created by any of the above 3 tasks.

Test that your testing environment is set up correctly:

Run `rake test:bot:environment` and make sure all the tests pass.

You now have effective_test_bot configured and you're ready to go.

# How to use this gem

Effective TestBot provides 4 different layers of support to a developer writing minitest capybara feature tests:

1.) a whole bunch of individual minitest assertions and capybara quality of life helper functions.

2.) one-liner test suites -- run entire test suites (10-50+ assertions) against a page, or use these methods to aid in writing larger feature tests.

3.) record animated .gifs of test runs - enable auto-save on failure or run in tour mode to generate feature walkthroughs.

4.) full application automated testing - run `rake test:bot` to scan every route in your application and choose an appropriate test suite to run.

## Minitest Assertions

The following assertions are added for use in any minitest & capybara integration test:

- `assert_signed_in` visits the devise `new_user_session_path` and checks for the `devise.failure.already_authenticated` content.
- `assert_signed_out` visits the devise `new_user_session_path` and checks for absense of the `devise.failure.already_authenticated` content.
- `assert_page_title` makes sure there is an html <title></title> present.
- `assert_submit_input` makes sure there is an input[type='submit'] present.
- `assert_page_status` checks for a given http status, default 200.
- `assert_current_path(path)` asserts the current page path.
- `assert_redirect(from_path)` optionally with to_path, makes sure the current page path is not from_path.
- `assert_no_js_errors` - checks for any javascript errors on the page.
- `assert_no_unpermitted_params` makes sure the last submitted form did not include any unpermitted params and prints out any unpermitted params that do exist.
- `assert_no_exceptions` checks for any exceptions in the last page request and gives a stacktrace if there was.
- `assert_no_html_form_validation_errors` checks for frontend html5 errors.
- `assert_jquery_ujs_disable_with` makes sure all input[type=submit] elements on the page have the data-disable-with property set.
- `assert_flash` optionally with the desired :success, :error key and/or message, makes sure the flash is set.
- `assert_assigns` asserts a given rails view_assigns object is present.
- `assert_no_assigns_errors` use after a form submit to make sure your assigned rails object has no errors.  Prints out any errors if they exist.
- `assert_assigns_errors` use after an intentionally invalid form submit to make sure your assigned rails object has errors, or a specific error.

## Capybara Extras

The following quality of life helpers are added for use in any minitest & capybara integration test:

### fill_form

Finds all the input, select and textarea form fields on the current page and fills them with pseudo-random appropriate values.

Detects names, addresses, start and end dates, telephone numbers, postal and zip codes, file, price, email, numeric, password and password confirmation fields. Probably more.

Will only fill visible fields that are currently visible and not disabled.

If a selection made in one field changes the visibility/disabled of fields later in the form, those fields will be properly filled.

It works with the [cocoon](https://github.com/nathanvda/cocoon), [select2](https://select2.github.io/) and [effective_assets](https://github.com/code-and-effect/effective_assets) gems.

It will click through bootstrap tabs and fill them left-to-right one tab at a time.

You can pass a Hash of 'fills' to specify specific input values:

```ruby
require 'test_helper'

class PostTest < ActionDispatch::IntegrationTest
  test 'creating a new post' do
    visit new_post_path
    fill_form(:title => 'A Cool Post', 'author.last_name' => 'Smith')
    submit_form
  end
end
```

And you can disable specific fields from being filled, by modifying the input html in your normal view:

```ruby
= f.input :too_complicated, 'data-test-bot-skip' => true
```

Sometimes you have the requirement that inputs add upto a certain number.  For example, having to provide percentages in 3-4 input fields that always add upto 100%.

You can use the html `min` and `max` properties to indicate this requirement.

The `min` and `max` html properties are considered when filling in any numeric field -- the fill value will always be within the specified range.

If there are 2 or more numeric inputs that end with the same jquery selector, the fields will be filled so that their sum will match the html `max` value.

You can scope the fill_form to a particular area of the page by using the regular capybara `within` `do..end` block

### submit_form

As well as just click on the `input[type='submit']` button (or optional label), this helper also checks:
- `assert_no_html5_form_validation_errors`
- `assert_jquery_ujs_disable_with`
- `assert_no_unpermitted_params`

### other helpers

- `submit_novalidate_form` will use javascript to disable all required fields, and submit a form without client side validation.
- `clear_form` clears all form fields, probably used before `submit_novalidate_form` to test invalid form submissions.
- `sign_in(user)` optionally with user, signs in via `Warden::Test::Helpers` hacky login skipping method.
- `sign_in_manually(user, password)` visits the devise `new_user_session_path` and signs in via the form.
- `sign_up` visits the devise `new_user_registration_path` and signs up as a new user.
- `as_user(user) do .. end` yields a block between `sign_in`, and `logout`.
- `synchronize!` should fix any timing issues waiting for capybara elements.
- `was_redirect?` returns true/false if the last time we changed pages was a 304 redirect.
- `was_download?` if clicking a link returned a file of any type rather than a page change.

## Capybara Super Extras

So the problem with running integration tests with capybara-webkit is that it's a real full black-box integration test.

Capybara runs in a totally separate process.  It knows nothing about your application.  You can't get access to any of the rails internal state. All you can test is html, javascript and urls. That really sucks.

effective_test_bot mixes in a rails controller include and does a bit of http header hackery to make available to capybara the internal rails state values that are just so handy.

The following are refreshed on each page change, and are available to check anywhere in your tests.

- `flash` a Hash representation of the current page's flash
- `assigns` a Hash representation of the current page's rails `view_assigns`. Serializes any ActiveRecord objects, as well as any TrueClass, FalseClass, NilClass, String, Symbol, Numeric objects.  Does not serialize anything else, but sets a symbol `assigns[key] == :present_but_not_serialized`.
- `exceptions` an Array with the exception message and a stacktrace.
- `unpermitted_params` an Array of any unpermitted paramaters that were encountered by the last request

- `save_test_bot_screenshot` saves a screenshot of the current page to be added to the current test's animated gif (see screenshots and tour mode below).

## Test Bot DSL Methods

All of the following DSL methods run an entire test suites against a given page or controller action.

They are intended to be used both as standalone one-liners, like [shoulda-matchers](https://github.com/thoughtbot/shoulda-matchers), and as helper methods to aid in writing custom tests quickly.

Each method has a class-level/one-liner `x_test` and an instance level `x_action_test` version.

### crud_test

This test runs through the [CRUD](http://edgeguides.rubyonrails.org/getting_started.html) workflow of a given controller and checks that resource creation functions as expected -- that all the model, controller, views and database actually work -- and tries to enforce as many best practices as possible.

There are 9 different `crud_action_test` test suites that can be run individually. The class level `crud_test` runs all of them at once.

The following `crud_action_test`s are available:

- `:index` - signs in as the given user, finds or creates a resource, visits `resources_path` and checks that a collection of resources has been assigned.
- `:new` - signs in as the given user, visits `new_resource_path`, and checks for a properly named form appropriate to the resource.
- `:create_invalid` - signs in as the given user, visits `new_resource_path` and submits an empty form. Checks that all errors are properly assigned and makes sure a new resource was not created.
- `:create_valid` - signs in as the given user, visits `new_resource_path`, and submits a valid form.  Checks for any errors and makes sure a new resource was created.
- `:show` - signs in as the given user, finds or creates a resource, visits `resource_path` and checks that the resource is shown.
- `:edit` - signs in as the given user, finds or creates a resource, visits `edit_resource_path` and checks that an appropriate form exists for this resource.
- `:update_invalid` - signs in as the given user, finds or creates a resource, visits `edit_resource_path` and submits an empty form.  Checks that the existing resource wasn't updated and that all errors are properly assigned and displayed.
- `:update_valid` - signs in as the given user, finds or creates a resource, visits `edit_resource_path` and submits a valid form. Checks for any errors and makes sure the existing resource was updated.
- `:destroy` - signs in as the given user, finds or creates a resource, visits `resources_path`.  It then finds or creates a link to destroy the resource and clicks the link.  Checks for any errors and makes sure the resource was deleted.  If the resource `respond_to?(:archived)` it will check for archive behavior instead of delete.

Also,

- `:tour` - signs in as a given user and runs all of the above `crud_action_test`s inside one test.  The animated .gif produced from this test suite records the entire process of creating, showing, editing and deleting a resource from start to finish.  It also makes all the same assertions as running the test suites individually.


A quick note on speed:  You can speed up these test suites by fixturing, seeding or first creating an instance of the resource being tested. Any tests that need to `find_or_create_resource` check for an existing resource first, otherwise visit `new_resource_path` and submit a form to create the resource.  Having a resource already created will speed up these test suites.

There are a few variations on the one-liner method:

```ruby
class PostsTest < ActionDispatch::IntegrationTest
  # Runs all 9 crud_action tests against /posts
  crud_test(Post, User.first)

  # Runs all 9 crud_action tests against /posts and use this Post's attributes when calling fill_form.
  crud_test(Post.new(title: 'my first post'), User.first)

  # Runs all 9 crud_action tests against /admin/posts controller as a previously seeded or fixtured admin user
  crud_test('admin/posts', User.where(admin: true).first)

  # Run only some tests
  crud_test(Post, User.first, only: [:new, :create_valid, :create_invalid, :show, :index])

  # Run all except some tests
  crud_test(Post, User.first, except: [:edit, :update_valid, :update_invalid])

  # Skip individual assertions
  crud_test(Post, User.first, skip: {create_valid: :path, update_invalid: [:path, :flash]})
end
```

Or each individually in part of a regular test:

```ruby
class PostsTest < ActionDispatch::IntegrationTest
  test 'user is locked out after failing to update twice' do
    crud_action_test(:create_valid, Post, User.first)
    assert_content 'successfully created post.  You can only edit it once.'

    crud_action_test(:update_valid, Post.last, User.first)
    assert_content 'successfully updated post.'

    crud_action_test(:update_valid, Post.last, User.first, skip: [:no_assigns_errors, :updated_at])
    assert_assigns_errors(:post, 'you can no longer update this post')
    assert_content 'you can no longer update this post.'
  end
end
```

If your resource controller passes a `crud_test` you can be certain that your application's end user will be able to do the same.

### devise_test

This test runs through the the [devise](https://github.com/plataformatec/devise) sign up, sign in, and sign in invalid workflows.

- `devise_action_test(:sign_up)` visits the devise `new_user_registration_path`, and `submit_form` and validates the `current_user`.
- `devise_action_test(:sign_in)` creates a new user and makes sure the sign in process works.
- `devise_action_test(:sign_in_invalid)` makes sure an invalid password is correctly denied.

Use as a one-liner method:

```ruby
class MyApplicationTest < ActionDispatch::IntegrationTest
  devise_test  # Runs all tests (sign_up, sign_in_valid, and sign_in_invalid)
end
```

Or each individually in part of a regular test:

```ruby
class MyApplicationTest < ActionDispatch::IntegrationTest

  test 'user receives 10 tokens after signing up' do
    devise_action_test(:sign_up)
    assert_content 'Tokens: 10'
    assert_equals 10, User.last.tokens
    assert_equals 10, assigns(:current_user).tokens
  end
end
```

### page_test

This test signs in as the given user, visits the given page and simply checks `assert_page_normal`.

Use it as a one-liner method:

```ruby
class PostsTest < ActionDispatch::IntegrationTest
  page_test(:posts_path, User.first)  # Runs the page_test test suite against posts_path as User.first
end
```

Or as part of a regular test:

```ruby
class PostsTest < ActionDispatch::IntegrationTest
  test 'posts are displayed on the index page' do
    Post.create(title: 'first post')

    page_action_test(:posts_path, User.first)

    assert page.current_path, '/posts'
    assert_content 'first post'
  end
end
```

### member_test

This test is intended for non-CRUD actions that operate on a specific instance of a resource.

The action must be a `GET` with a required `id` value.  `member_test`-able actions will look like the following in `rake routes`:

```ruby
unarchive_post  GET  /posts/:id/unarchive(.:format)  posts#unarchive
```

This test signs in as the given user, visits the given controller/action/page and checks `assert_page_normal` and `assert_assigns`.

Use it as a one-liner method:

```ruby
class PostsTest < ActionDispatch::IntegrationTest
  member_test('posts', 'unarchive', User.first, Post.find(1))  # Run the member_test specifically with Post.find(1)
  member_test('posts', 'unarchive', User.first)                # Uses find_or_create_resource! to load a seeded resource or create a new one
end
```

Or as part of a regular test:

```ruby
class PostsTest < ActionDispatch::IntegrationTest
  test 'posts can be unarchived' do
    post = Post.create(title: 'first post', archived: true)

    assert Post.where(archived: false).empty?
    member_action_test('posts', 'unarchive', User.first, post)
    assert Post.where(archived: false).present?
  end
end
```

### redirect_test

This test signs in as the given user, visits the given page and checks `assert_redirect(from_path, to_path)` and `assert_page_normal`.

Use it as a one-liner method:

```ruby
class PostsTest < ActionDispatch::IntegrationTest
  redirect_test('/blog', '/posts', User.first)  # Visits /blog and tests that it redirects to a working /posts page
end
```

Or as part of a regular test:

```ruby
class PostsTest < ActionDispatch::IntegrationTest
  test 'visiting blog redirects to posts' do
    Post.create(title: 'first post')
    redirect_action_test('/blog', '/posts', User.first)
    assert_content 'first post'
  end
end
```

### wizard_test

This test signs in as the given user, visits the given initial page and continually runs `fill_form`, `submit_form` and `assert_page_normal` up until the given final page, or until no more `input[type=submit]` are present.

It tests any number of steps in a wizard, multi-step form, or inter-connected series of pages.

As well, in the `wizard_action_test`, each page is yielded to the calling test.

Use it as a one-liner method:

```ruby
class PostsTest < ActionDispatch::IntegrationTest
  wizard_test('/build_post/step1', '/build_post/step5', User.first)
end
```

Or as part of a regular test:

```ruby
class PostsTest < ActionDispatch::IntegrationTest
  test 'building a post in 5 steps works' do
    wizard_action_test('/build_post/step1', '/build_post/step5', User.first) do
      if page.current_path.end_with?('step4')
        assert_content 'your post is ready but must first be approved by an admin.'
      end
    end
  end
end
```

## Automated Testing / Rake tasks

```ruby
rake test:bot:environment
rake test:bot
rake test:bot TEST=posts
rake test:bot TEST=posts#index
```

### Skipping assertions and tests

Each of these DSL test suite methods are designed to assert an expected standard rails behaviour.

But sometimes a developer has a good reason for deviating from what is considered standard; therefore, each individual assertion is skippable.

When an assertion fails, the minitest output will look something like:

```console
crud_test: (users#update_invalid)                               FAIL (3.74s)

Minitest::Assertion: (current_path) Expected current_path to match resource #update path.
  Expected: "/users/562391275"
  Actual: "/members/562391275"
  /Users/matt/Sites/effective_test_bot/test/test_botable/crud_test.rb:155:in `test_bot_update_invalid_test'
```

The `(current_path)` is the name of the specific assertion that failed.

The expectation is that when submitting an invalid form at `/users/562391275/edit` we should be returned to the update action url `/users/562391275`, but in this totally reasonable but not-standard case we are redirected to `/members/562391275` instead.

You can skip this assertion by adding it to the `app/config/initializers/effective_test_bot.rb` file:

```ruby
EffectiveTestBot.setup do |config|
  config.except = [
    'users#create_invalid current_path',  # Skips the current_path assertion for just the users#create_invalid test
    'current_path',                       # Skips the current_path assertion entirely in all tests
    'users#create_invalid'                # Skips the entire users#create_invalid test
  ]
end
```

There is support for skipping individual assertions, entire tests, or a combination of both.

Please see the installed effective_test_bot.rb initializer file for a full description of all options.

TODO

## Screenshots and Animated Gifs

TODO

### Tour mode

```ruby
rake test:bot:tour
rake test:bot:tour TEST=posts
rake test:bot:tourv # verbose mode
```

```ruby
rake test:bot:tours # Prints out file location of all tour animated .gifs
rake test:bot:purge # Deletes all tour and failure animated .gifs
```

TODO


## License

MIT License.  Copyright [Code and Effect Inc.](http://www.codeandeffect.com/)

Code and Effect is the product arm of [AgileStyle](http://www.agilestyle.com/), an Edmonton-based shop that specializes in building custom web applications with Ruby on Rails.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Bonus points for test coverage
6. Create new Pull Request
