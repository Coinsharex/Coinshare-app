require 'dry-validation'

module Types
  include Dry::Types()

  Name = Types::String.constructor do |str|
    str ? str.strip.chomp : str
  end
end

SignUpForm = Dry::Validation.Params do
  configure do
    config.type_specs = true
  end

  required(:email, :string).filled(format?: /.@.+[.][a-z]{2,}/i)
  required(:name, Types::Name).filled(min_size?: 1)
  required(:password, :string).filled(min_size?: 6)
end

result = SignUpForm.call(
  'name' => "\t François Joceline \n",
  'email' => 'francois@teksol.info',
  'password' => 'some password'
)

result.success?
# true

result[:name]
# "François"
