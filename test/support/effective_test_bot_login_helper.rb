# This is all assuming you're running Devise

module EffectiveTestBotLoginHelper
  def as_user(user)
    sign_in(user); @test_bot_user = user
    yield
    sign_out; @test_bot_user = nil
  end

  # This is currently hardcoded to use the warden login_as test helper
  def sign_in(user)
    if user.kind_of?(String)
      login_as(User.find_by_email!(user))
    elsif user.kind_of?(User)
      raise 'user must be persisted' unless user.persisted?
      user.reload
      login_as(user)
    elsif user == false
      true # Do nothing
    else
      raise 'sign_in(user) expected a User or an email String'
    end
  end

  # This is currently hardcoded to use the warden logout test helper
  def sign_out
    logout
  end

  def sign_in_manually(user_or_email, password = nil)
    visit new_user_session_path

    email = (user_or_email.respond_to?(:email) ? user_or_email.email : user_or_email)
    username = (user_or_email.respond_to?(:username) ? user_or_email.username : user_or_email)
    login = (user_or_email.respond_to?(:login) ? user_or_email.login : user_or_email)

    within('form#new_user') do
      fill_form(email: email, password: password, username: username, login: login)
      submit_novalidate_form
    end
  end

  def sign_up(email: Faker::Internet.email, password: Faker::Internet.password, **options)
    visit new_user_registration_path

    within('form#new_user') do
      fill_form({email: email, password: password, password_confirmation: password}.merge(options))
      submit_novalidate_form
    end

    User.find_by_email(email)
  end

  def current_user
    User.where(id: assigns['current_user']['id']).first if (assigns['current_user'] && assigns['current_user']['id'])
  end

end
