# ACube API - Rails [WIP]
Wrapper library around the ACube API for ruby on rails. Quickly set up resources to manage invoices.

## Usage
This will copy over the initializer file to your rails application and the necessary migrations:
```
$ bin/rails g a_cube:install
```

In the initializer file you have to set at the very least the following:
```ruby
config.username = "your-login-email"
config.password = "your-login-password"

config.invoice_endpoint = ENV.fetch('ACUBE_INVOICE_ENDPOINT', "https://api-sandbox.acubeapi.com")
config.common_endpoint = ENV.fetch('ACUBE_COMMON_ENDPOINT', "https://common-sandbox.api.acubeapi.com")
```

For a complete list of configuration options, see the initializer file.  
You have to designate two models to be used that will serve as the supplier/consumer contacts.
These will take care of the mapping between your application and the ACube API.
```ruby
include ACube::Support::Supplier

as_supplier do |s|
  s.first_name = "..."
  s.last_name = :last_name
end
```
String means constant value, symbol means method name on the model that will get called when the invoice is created.

```ruby
include ACube::Support::Consumer

as_custoemr do |c|
  c.first_name = "..."
  c.last_name = :last_name
end
```
For a full list of supported attributes, see the relevant file.

The last model is the one that will be associated with the invoices, so the payment model per say.
```ruby
class Payment < ApplicationRecord
  has_one_invoice :invoice

  as_transaction do |t|
    t.amount = :amount
    t.currency = "EUR"
    t.payment_date = :created_at
  end
end
```
The `has_one_invoice` method will create the association between the payment and the invoice.
The `as_transaction` method will create the mapping between the payment and the invoice.

The last step is to actually publish the invoice to the ACube API.
```ruby
# In your controller somewhere
def create
  @payment = Payment.new(payment_params)
  supplier = Supplier.new(...)
  consumer = Consumer.new(...)

  if @payment.save
    @payment.publish_invoice(supplier, consumer, :FPR12)
    # ...
  end
end
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem "acube-rails", require: "acube"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install acube-rails
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
