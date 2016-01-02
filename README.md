# Effective TestBot

Stop testing and start test botting.

A minitest library of capybara-webkit based feature tests that should pass in every Ruby on Rails application.

Adds many additional minitest assertions and capybara quality of life helper functions.

Provides a curated set of minitest/capybara/rails testing gems and a well configured `test_helper.rb` minitest file.

Run `rake test:bot:environment` to validate your testing environment.  Ensures that all fixtures and seeds are properly initialized.  Makes sure database transactions and web sessions correctly reset between tests.

Adds many class and instance level 1-liners to run entire test suites and check many assertions all at once.

Autosaves an animated .gif for any failing test.

Run `rake test:bot` to automatically check every route in your application against an appropriate test suite, without writing any code.  Clicks through every page, intelligently fills forms with appropriate pseudo-random input and checks for all kinds of errors and omissions.

Turn on tour mode to programatically generate an animated .gif of every workflow in your website.

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

```
bundle install
```

Install the configuration file:

```
rails generate effective_test_bot:install
```

The generator will run `minitest:install` if minitest is not already present and create an initializer file which describes all configuration options.

Fixture or seed one user. At least one user -- ideally a fully priviledged admin type user -- must be available in the testing environment.

(there are future plans to make this better.  Right now `rake test:bot` just runs everything as one user.  There really isn't support for 'this user should not be able to' yet.)

To create the initial user, please add it to either `test/fixtures/users.yml`, the `db/seeds.db` file or the effective_test_bot specific `test/fixtures/seeds.rb` file.

As per the included `test/test_helper.rb`, the following tasks run when minitest starts:

```ruby
# Rails default task, load fixtures from test/fixtures/*.yml (including users.yml if it exists)
rake db:fixtures:load

# Rails default task, loads db/seeds.rb
rake db:seed

# Added by effective_test_bot.  loads test/fixtures/seeds.rb. 'cause screw yaml.
rake test:load_fixture_seeds
```

Your initial user may be created by any of the above 3 tasks.



Finally, to test that your testing environment is set up correctly run `rake test:bot:environment` and have all tests pass.

You now have effective_test_bot configured and you're ready to go.

# How to use this gem

Effective TestBot provides 4 different layers of support to a developer writing minitest capybara feature tests:

1.) enjoy a whole bunch of individual minitest assertions and capybara quality of life helper functions.

2.) call one-liner methods to run test suites (10-50+ assertions) against a page, or use these methods to build larger tests.

3.) produce animated .gifs of test runs. Enable auto-save on failure to help debug a tricky test, or run in tour mode and record walkthroughs of features.

4.) apply full stack automated testing - run `rake test:bot` to scan every route in your application and check it with an appropriate test suite.

## Minitest Assertions

The following assertions are added for use in any minitest & capybara integration test:

- `assert_signed_in` visits the devise `new_user_session_path` and checks for the already signed in content.
- `assert_signed_out` visits the devise `new_user_session_path` and checks for the sign in content.
- `assert_page_title` makes sure there is an html `<title></title>` present.
- `assert_submit_input` makes sure there is an `input[type='submit']` present.
- `assert_page_status` checks for a given http status, default 200.
- `assert_current_path(path)` asserts the current page path.
- `assert_redirect(from_path)` optionally with to_path, makes sure the current page path is not from_path.
- `assert_no_js_errors` - checks for any javascript errors on the page.
- `assert_no_unpermitted_params` makes sure the last submitted form did not include any unpermitted params and prints out any unpermitted params that do exist.
- `assert_no_exceptions` checks for any exceptions in the last page request and gives a stacktrace if there was.
- `assert_no_html_form_validation_errors` checks for frontend html5 errors.
- `assert_jquery_ujs_disable_with` makes sure all `input[type=submit]` elements on the page have the `data-disable-with` property set.
- `assert_flash`, optionally with the desired `:success`, `:error` key and/or message, makes sure the flash is set.
- `assert_assigns` asserts a given rails view_assigns object is present.
- `assert_no_assigns_errors` should be used after any form submit to make sure your assigned rails object has no errors.  Prints out any errors if they exist.
- `assert_assigns_errors` use after an intentionally invalid form submit to make sure your assigned rails object has errors, or a specific error.

As well,

- `assert_page_normal` checks for general errors on the current page.  Checks include  `assert_no_exceptions`, `assert_page_status`, `assert_no_js_errors`, and `assert_page_title`.

## Capybara Extras

The following quality of life helpers are added for use in any minitest & capybara integration test:

### fill_form

Finds all input, select and textarea form fields and fills them with pseudo-random but appropriate values.

Intelligently fills names, addresses, start and end dates, telephone numbers, postal and zip codes, file, price, email, numeric, password and password confirmation fields. Probably more.

Will only fill visible fields that are currently visible and not disabled.

If a selection made in one field changes the visibility/disabled of fields later in the form, those fields will be properly filled.

It clicks through bootstrap tabs and fill them nicely left-to-right, one tab at a time, and knows how to work with [cocoon](https://github.com/nathanvda/cocoon), [select2](https://select2.github.io/) and [effective_assets](https://github.com/code-and-effect/effective_assets) form fields.

You can pass a Hash of 'fills' to specify specific input values:

```ruby
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

Clicks the first `input[type='submit']` field (or with the given label) and submits a form.

Automatically checks for `assert_no_html5_form_validation_errors`, `assert_jquery_ujs_disable_with` and `assert_no_unpermitted_params`

```ruby
class PostTest < ActionDispatch::IntegrationTest
  test 'creating a new post' do
    visit new_post_path
    fill_form
    submit_form    # or submit_form('Save and Continue')
  end
end
```

### other helpers

- `submit_novalidate_form` submits the form without client side validation, ignoring any required field requirements.
- `clear_form` clears all form fields, probably used before `submit_novalidate_form` to test invalid form submissions.
- `sign_in(user)` optionally with user, signs in via `Warden::Test::Helpers` hacky login skipping method.
- `sign_in_manually(user, password)` visits the devise `new_user_session_path` and signs in via the form.
- `sign_up` visits the devise `new_user_registration_path` and signs up as a new user.
- `as_user(user) do .. end` yields a block between `sign_in`, and `logout`.
- `synchronize!` should fix any timing issues waiting for capybara elements.
- `was_redirect?` returns true/false if the last time we changed pages was a 304 redirect.
- `was_download?` if clicking a link returned a file of any type rather than a page change.

## Capybara Super Extras

Running integration tests with capybara-webkit is truly a black-box integration testing experience.  This provides a lot of benefits, but also some severe limitations.

Capybara runs in a totally separate process.  It knows nothing about your application and it does not have access to any of the rails internal state. It only sees html, javascript, css and urls.

effective_test_bot extends this knowledge by adding a rails controller mixin and some http header hackery. In turn making available to capybara the internal rails state, which is just so handy.  This allows minitest to read back those values and take a peek inside the black box.

The following are refreshed on each page change, and are available to check anywhere in your tests:

- `flash` a Hash representation of the current page's flash.
- `assigns` a Hash representation of the current page's rails `view_assigns`. Serializes any `ActiveRecord` objects, as well as any `TrueClass`, `FalseClass`, `NilClass`, `String`, `Symbol`, and `Numeric` objects.  Does not serialize anything else, but sets a symbol `assigns[key] == :present_but_not_serialized`.
- `exceptions` an Array with the exception message and a stacktrace.
- `unpermitted_params` an Array of any unpermitted parameters that were encountered by the last request.

- `save_test_bot_screenshot` saves a screenshot of the current page to be added to the current test's animated gif (see screenshots and tour mode below).

## Effective Test Suites

Each of the following test suites make 10-50+ assertions on a given page or controller action.  The idea is to check for every possible error or omission accross all layers of the stack.

These may be used as standalone one-liners, in the style of [shoulda-matchers](https://github.com/thoughtbot/shoulda-matchers) and as helper methods to quickly build up more advanced tests.

Each test suite has a class-level one-liner `x_test` and and one or more instance level `x_action_test` versions.

### crud_test

This test runs through the standard [CRUD](http://edgeguides.rubyonrails.org/getting_started.html) workflow of a given controller and checks that resource creation functions as expected -- that all the model, controller, views and database actually work -- and tries to enforce best practices.

There are 9 different `crud_action_test` test suites that may be run individually. The one-liner `crud_test` runs all of them.

The following instance level `crud_action_test` methods are available:

- `crud_action_test(:index)` signs in as the given user, finds or creates a resource, visits `resources_path` and checks that a collection of resources has been assigned.
- `crud_action_test(:new)` signs in as the given user, visits `new_resource_path`, and checks for a properly named form appropriate to the resource.
- `crud_action_test(:create_invalid)` signs in as the given user, visits `new_resource_path` and submits an empty form. Checks that all errors are properly assigned and makes sure a new resource was not created.
- `crud_action_test(:create_valid)` signs in as the given user, visits `new_resource_path`, and submits a valid form.  Checks for any errors and makes sure a new resource was created.
- `crud_action_test(:show)` signs in as the given user, finds or creates a resource, visits `resource_path` and checks that the resource is shown.
- `crud_action_test(:edit)` signs in as the given user, finds or creates a resource, visits `edit_resource_path` and checks that an appropriate form exists for this resource.
- `crud_action_test(:update_invalid)` signs in as the given user, finds or creates a resource, visits `edit_resource_path` and submits an empty form.  Checks that the existing resource wasn't updated and that all errors are properly assigned and displayed.
- `crud_action_test(:update_valid)` signs in as the given user, finds or creates a resource, visits `edit_resource_path` and submits a valid form. Checks for any errors and makes sure the existing resource was updated.
- `crud_action_test(:destroy)` signs in as the given user, finds or creates a resource, visits `resources_path`.  It then finds or creates a link to destroy the resource and clicks the link.  Checks for any errors and makes sure the resource was deleted.  If the resource `respond_to?(:archived)` it will check for archive behavior instead of delete.

Also,

- `crud_action_test(:tour)` signs in as a given user and calls all the above `crud_action_test` methods from inside one test.  The animated .gif produced from this test suite records the entire process of creating, showing, editing and deleting a resource from start to finish.  It makes all the same assertions as running the test suites individually.


A quick note on speed:  You can speed up these test suites by fixturing, seeding or first creating an instance of the resource being tested. Any tests that need to `find_or_create_resource` check for an existing resource first, otherwise visit `new_resource_path` and submit a form to create the resource.  Having a resource already created will speed things up.

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

The individual test suites may also be used as part of a larger test:

```ruby
class PostsTest < ActionDispatch::IntegrationTest
  test 'user may only update a post once' do
    crud_action_test(:create_valid, Post, User.first)
    assert_content 'successfully created post.  You may only update it once.'

    crud_action_test(:update_valid, Post.last, User.first)
    assert_content 'successfully updated post.'

    crud_action_test(:update_valid, Post.last, User.first, skip: [:no_assigns_errors, :updated_at])
    assert_assigns_errors(:post, 'you may no longer update this post.')
    assert_content 'you may no longer update this post.'
  end
end
```

If your resource controller passes a `crud_test` you can be certain that your user is able to correctly create, edit, display and delete a resource without encountering any application errors.

### devise_test

This test runs through the the [devise](https://github.com/plataformatec/devise) sign up, sign in, and sign in invalid workflows.

- `devise_action_test(:sign_up)` visits the devise `new_user_registration_path`, submits the sign up form and validates the `current_user`.
- `devise_action_test(:sign_in)` creates a new user and makes sure the sign in process works.
- `devise_action_test(:sign_in_invalid)` makes sure an invalid password is correctly denied.

Use as a one-liner:

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

### member_test

This test is intended for non-CRUD actions that operate on a specific instance of a resource.

The action must be a `GET` with a required `id` value.  `member_test`-able actions appear as follows from `rake routes`:

```
unarchive_post  GET  /posts/:id/unarchive(.:format)  posts#unarchive
```

This test signs in as the given user, visits the given controller/action/page and checks `assert_page_normal` and `assert_assigns`.

Use it as a one-liner:

```ruby
class PostsTest < ActionDispatch::IntegrationTest
  # Uses find_or_create_resource! to load a seeded resource or create a new one
  member_test('posts', 'unarchive', User.first)

  # Run the member_test with a specific post
  member_test('posts', 'unarchive', User.first, Post.find(1))
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

### page_test

This test signs in as the given user, visits the given page and simply checks `assert_page_normal`.

Use it as a one-liner:

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

### redirect_test

This test signs in as the given user, visits the given page then checks `assert_redirect(from_path, to_path)` and `assert_page_normal`.

Use it as a one-liner:

```ruby
class PostsTest < ActionDispatch::IntegrationTest
  # Visits /blog and tests that it redirects to a working /posts page
  redirect_test('/blog', '/posts', User.first)
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

As well, in the `wizard_action_test`, each page is yielded to the calling method.

Use it as a one-liner:

```ruby
class PostsTest < ActionDispatch::IntegrationTest
  wizard_test('/build_post/step1', '/build_post/step5', User.first)
end
```

Or as part of a regular test:

```ruby
class PostsTest < ActionDispatch::IntegrationTest
  test 'building a post in 5 steps' do
    wizard_action_test('/build_post/step1', '/build_post/step5', User.first) do
      if page.current_path.end_with?('step4')
        assert_content 'your post is ready but must first be approved by an admin.'
      end
    end
  end
end
```

## Skipping assertion in test suites

Each of the test suites checks a page or pages for some expected behaviour.  Sometimes a developer has a good reason for deviating from what is expected and it's frustrating when just one assertion in a test suite fails.

So, almost every individual assertion made by these test suites is skippable.

When an assertion fails, the minitest output will look something like:

```console
crud_test: (users#update_invalid)                               FAIL (3.74s)

Minitest::Assertion: (current_path) Expected current_path to match resource #update path.
  Expected: "/users/1"
  Actual: "/members/1"
  /Users/matt/Sites/effective_test_bot/test/test_botable/crud_test.rb:155:in `test_bot_update_invalid_test'
```

Here, the `(current_path)` is the name of the specific test bot assertion that failed.

The expectation is that when submitting an invalid form at `/users/1/edit` we should be returned to the update action url `/users/1`, but in this totally reasonable but not-standard case we are redirected to `/members/1` instead.

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

Please see the installed `effective_test_bot.rb` initializer file for a full description of all options.

## Testing the test environment

Unfortunately, in the current day ruby on rails ecosystem simply getting a testing environment setup correctly is a non-trivial endeavor.

There are a handful of gotchas and many things that can go wrong.  User sessions need to properly reset and database transactions must be correctly rolled back between tests.  Seeds and fixtures that were once valid may become invalid as the application changes.  Database migrations must also stay up to date.  Capybara needs to query your app with a single shared connection or weird things start happening.

Included with this gem is the `rails generate effective_test_bot:install` that does its best to provide a known-good set of configuration files that initialize all required testing gems.  However, every developer's machine is different, and there are too many points of failure.  Everyone's `test/test_helper.rb` will be slightly different.

Run `rake test:bot:environment` to check for capybara doing the right thing, that everything is reset properly between test runs, an initial user record exists, all seeded and fixtured data is valid, that jquery, jquery-ujs are present.

If all tests here pass, you will have a great experience with automated testing.

## Automated full stack testing

One of the main goals of `effective_test_bot` is to increase the speed at which tests can be written in any ruby on rails application.  Well, there's no faster way of writing tests than by not writing them at all.

Run `rake test:bot` to scan every route defined in `routes.rb` and run an appropriate test suite.

You can configure test bot to skip individual tests or assertions, tweak screenshot behaviour and toggle tour mode via the `config/initializers/effective_test_bot.rb` file.  As well, there are a few command line options available.

These are some quick ways to customize test bot's behaviour:

```ruby
# Scan every route in the application as per config/initializers/effective_test_bot.rb
rake test:bot

# Test a specific controller (any routes matching posts)
rake test:bot TEST=posts

# Test a specific controller and action
rake test:bot TEST=posts#index
```

## Screenshots and Animated Gifs

Call `save_test_bot_screenshot` from within your test to take a screenshot of the current page.  If an animated .gif is produced at the end of the test -- either from autosave_animated_gif_on_failure or tour mode -- this screenshot will be used as one of the frames in the animation.

This method is already called by `fill_form` and `submit_form`.

To disable taking screenshots entirely, change `config.screenshots = false` in the `config/initializers/effective_test_bot.rb` initializer file.

### Autosave animated .gif on failure

The `test/test_helper.rb` file that is installed by `effective_test_bot` enables [capybara-screenshot](https://github.com/mattheworiordan/capybara-screenshot)'s `autosave_on_failure` functionality.  So whenever a test fails, the current html will be written and a .png screenshot will be saved.  This is invaluable for troubleshooting why a test has failed.

Building on this type of feature, `effective_test_bot` will also autosave an animated gif on failure.  This does slow down failing tests and can be disabled.

### Tour mode

When running in tour mode, an animated .gif image file, a "tour", will be created for all successful tests.

This feature is slow, increasing the runtime of each test by almost 30%, but it's also really cool.

You can run test bot in tour mode by setting `config.tour_mode = true` in the `config/initializers/effective_test_bot.rb` file or by running any variation of the following rake tasks:

```ruby
# Run test:bot in tour mode, saving an animated .gif for all successful tests
rake test:bot:tour
rake test:bot TOUR=true

# Also prints the animated .gif file path to stdout
rake test:bot:tourv
rake test:bot TOUR=verbose

# Makes a whole bunch of extra screenshots when filling out forms
rake test:bot TOUR=extreme

# Runs in tour mode and tests only a specific controller or action
rake test:bot:tour TEST=posts
rake test:bot:tour TEST=posts#index
```

To print out the file location of all tour files, run the following:

```ruby
# Prints out all animated .gif file locations
rake test:bot:tours

# Prints out any animated .gif files locations with a file name matching posts
rake test:bot:tours TEST=posts
```

To delete all tour and autosave on failure animated .gifs, run the following:

```ruby
# Deletes all tour and failure animated .gifs
rake test:bot:purge
```

As well, to enable tour mode when running the standard minitest `rake test`:

```ruby
# Runs all regular minitest tests with tour mode enabled
rake test:tour
rake test:tourv
```

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
