# Active Call - Zoho CRM

[![Gem Version](https://badge.fury.io/rb/active_call-zoho_crm.svg?icon=si%3Arubygems)](https://badge.fury.io/rb/active_call-zoho_crm)

Zoho CRM exposes the [Zoho CRM API](https://www.zoho.com/crm/developer/docs/api) endpoints through [Active Call](https://rubygems.org/gems/active_call) service objects.

<div align="center">
  <a href="https://platform45.com?utm_source=github&utm_content=zoho_crm">
    <picture>
      <img src="https://github.com/user-attachments/assets/19fd40df-2ce9-4f30-8120-d53f3fbf9f07">
    </picture>
  </a>
</div>

- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Using call](#using-call)
  - [Using call!](#using-call!)
  - [When to use call or call!](#using-call-or-call!)
  - [Using lists](#using-lists)
- [Service Objects](#service-objects)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add active_call-zoho_crm
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install active_call-zoho_crm
```

## Configuration

Create a new **Self Client** client type from the [Zoho Developer Console](https://api-console.zoho.com) to retrieve your **Client ID** and **Client Secret**.

Choose what you need from the list of [Zoho Scopes](https://www.zoho.com/crm/developer/docs/api/v7/scopes.html) like `ZohoCRM.modules.ALL` to generate your **Grant Token**.

Get your **Refresh Token** by calling `ZohoCrm::GrantToken::GetService.call(grant_token: '', client_id: '', client_secret: '').refresh_token`

Configure your API credentials.

In a Rails application, the standard practice is to place this code in a file named `zoho_crm.rb` within the `config/initializers` directory.

```ruby
require 'active_call-zoho_crm'

ZohoCrm::BaseService.configure do |config|
  config.client_id = ''
  config.client_secret = ''
  config.refresh_token = ''

  # Optional configuration.
  config.cache = Rails.cache # Default: ActiveSupport::Cache::MemoryStore.new
  config.logger = Rails.logger # Default: Logger.new($stdout)
  config.logger_level = :debug # Default: :info
  config.log_headers = true # Default: false
  config.log_bodies = true # Default: false
end
```

## Usage

### <a name='using-call'></a>Using `call`

Each service object returned will undergo validation before the `call` method is invoked to access API endpoints.

After **successful** validation.

```ruby
service.success? # => true
service.errors # => #<ActiveModel::Errors []>
```

After **failed** validation.

```ruby
service.success? # => false
service.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=id, type=blank, options={}>]>
service.errors.full_messages # => ["Id can't be blank"]
```

After a **successful** `call` invocation, the `response` attribute will contain a `Faraday::Response` object.

```ruby
service.success? # => true
service.response # => #<Faraday::Response ...>
service.response.success? # => true
service.response.status # => 200
service.response.body # => {"data"=> [{"Email"=>"eric.cartman@example.com", ...}]}
```

At this point you will also have a `facade` object which will hold all the attributes for the specific resource.

```ruby
service.facade # => #<ZohoCrm::Record::Facade @attributes={"Email"=>"eric.cartman@example.com", ...} ...>
service.facade.attributes # => {"Email"=>"eric.cartman@example.com", ...}
```

For convenience, facade attributes can be accessed directly on the service object.

```ruby
service.attributes # => {"Email"=>"eric.cartman@example.com", ...}
```

After a **failed** `call` invocation, the `response` attribute will still contain a `Faraday::Response` object.

```ruby
service.success? # => false
service.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=base, type=bad_request, options={}>]>
service.errors.full_messages # => ["Bad Request"]
service.response # => #<Faraday::Response ...>
service.response.success? # => false
service.response.status # => 400
service.response.body # => {"data"=>[{"code"=>"INVALID_DATA", "details"=>{"api_name"=>"id", "json_path"=>"$.data[0].id"}, "message"=>"the id given seems to be invalid", "status"=>"error"}]}
```

### <a name='using-call!'></a>Using `call!`

Each service object returned will undergo validation before the `call!` method is invoked to access API endpoints.

After **successful** validation.

```ruby
service.success? # => true
```

After **failed** validation, a `ZohoCrm::ValidationError` exception will be raised with an `errors` attribute which 
will contain an `ActiveModel::Errors` object.

```ruby
rescue ZohoCrm::ValidationError => exception
  exception.message # => ''
  exception.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=id, type=blank, options={}>]>
  exception.errors.full_messages # => ["Id can't be blank"]
```

After a **successful** `call!` invocation, the `response` attribute will contain a `Faraday::Response` object.

```ruby
service.success? # => true
service.response # => #<Faraday::Response ...>
service.response.success? # => true
service.response.status # => 200
service.response.body # => {"data"=> [{"Email"=>"eric.cartman@example.com", ...}]}
```

At this point you will also have a `facade` object which will hold all the attributes for the specific resource.

```ruby
service.facade # => #<ZohoCrm::Record::Facade @attributes={"Email"=>"eric.cartman@example.com", ...} ...>
service.facade.attributes # => {"Email"=>"eric.cartman@example.com", ...}
```

For convenience, facade attributes can be accessed directly on the service object.

```ruby
service.attributes # => {"Email"=>"eric.cartman@example.com", ...}
```

After a **failed** `call!` invocation, a `ZohoCrm::RequestError` will be raised with a `response` attribute which will contain a `Faraday::Response` object.

```ruby
rescue ZohoCrm::RequestError => exception
  exception.message # => 'Bad Request'
  exception.errors # => #<ActiveModel::Errors [#<ActiveModel::Error attribute=base, type=bad_request, options={}>]>
  exception.errors.full_messages # => ["Bad Request"]
  exception.response # => #<Faraday::Response ...>
  exception.response.status # => 400
  exception.response.body # => {"data"=>[{"code"=>"INVALID_DATA", "details"=>{"api_name"=>"id", "json_path"=>"$.data[0].id"}, "message"=>"the id given seems to be invalid", "status"=>"error"}]}
```

### <a name='using-call-or-call!'></a>When to use `call` or `call!`

An example of where to use `call` would be in a **controller** doing an inline synchronous request.

```ruby
class SomeController < ApplicationController
  def update
    @service = ZohoCrm::Record::UpdateService.call(**params)

    if @service.success?
      redirect_to [@service], notice: 'Success', status: :see_other
    else
      flash.now[:alert] = @service.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end
end
```

An example of where to use `call!` would be in a **job** doing an asynchronous request.

You can use the exceptions to determine which retry strategy to use and which to discard.

```ruby
class SomeJob < ApplicationJob
  discard_on ZohoCrm::NotFoundError

  retry_on ZohoCrm::RequestTimeoutError, wait: 5.minutes, attempts: :unlimited
  retry_on ZohoCrm::TooManyRequestsError, wait: :polynomially_longer, attempts: 10

  def perform
    ZohoCrm::Record::UpdateService.call!(**params)
  end
end
```

### Using lists

If you don't provide the `per_page` argument, multiple API requests will be made untill all records have been returned. You could be rate limited, so use wisely.

## Service Objects

<details open>
<summary>Records</summary>

### Records

##### Supported modules

`Leads`, `Accounts`, `Contacts`, `Deals`, `Campaigns`, `Tasks`, `Cases`, `Events`, `Calls`, `Solutions`, `Products`, `Vendors`, `Price Books`, `Quotes`, `Sales Orders`, `Purchase Orders`, `Invoices`, `Custom`, `Appointments`, `Appointments Rescheduled History`, `Services` and `Activities`

##### Custom modules

For custom modules, use their respective API names in the request URL. You can obtain the API name from **Setup -> Developer Hub -> APIs & SDKs -> API Names**. You can also use the respective custom module's `api_name` key in the [Modules API's](https://www.zoho.com/crm/developer/docs/api/v7/modules-api.html) response to get the API name of the custom module.

#### List records

```ruby
# https://www.zoho.com/crm/developer/docs/api/v7/get-records.html

ZohoCrm::Record::ListService.call(module_name: 'Contacts', fields: 'Email,Last_Name', page: 1, per_page: 10).each do |facade|
  facade.attributes
end
```

Sort by column.

```ruby
ZohoCrm::Record::ListService.call(module_name: 'Contacts', fields: 'Email,Last_Name', sort_by: 'Modified_Time', sort_order: 'asc').map { _1 }
```

Columns to sort by are `id`, `Created_Time` and `Modified_Time`.

#### Search records

```ruby
# https://www.zoho.com/crm/developer/docs/api/v7/search-records.html

ZohoCrm::Record::SearchService.call(module_name: 'Contacts', email: 'eric.cartman@example.com', page: 1, per_page: 10).each do |facade|
  facade.attributes
end
```

Sort by column.

```ruby
ZohoCrm::Record::SearchService.call(module_name: 'Contacts', email: 'eric.cartman@example.com', sort_by: 'Modified_Time', sort_order: 'asc').map { _1 }
```

Columns to sort by are `id`, `Created_Time` and `Modified_Time`.

Search by email.

```ruby
ZohoCrm::Record::SearchService.call(module_name: 'Contacts', email: 'eric.cartman@example.com').map { _1 }
```

Search by phone.

```ruby
ZohoCrm::Record::SearchService.call(module_name: 'Contacts', phone: '0123456789').map { _1 }
```

Search by criteria.

```ruby
ZohoCrm::Record::SearchService.call(module_name: 'Contacts', criteria: 'Created_Time:between:2025-01-01T06:00:00+00:00,2025-01-30T06:00:00+00:00').map { _1 }
```

Search by word.

```ruby
ZohoCrm::Record::SearchService.call(module_name: 'Contacts', word: 'eric').map { _1 }
```

#### Get a record

```ruby
# https://www.zoho.com/crm/developer/docs/api/v7/get-records.html

service = ZohoCrm::Record::GetService.call(module_name: 'Contacts', id: '')
service.id
service.attributes
service.attributes['Email']
service.attributes['Record_Status__s']
service.attributes['Owner']['name']
...
```

#### Create a record

```ruby
# https://www.zoho.com/crm/developer/docs/api/v7/insert-records.html

ZohoCrm::Record::CreateService.call(
  module_name: 'Contacts',
  data: {
    'Email' => 'eric.cartman@example.com',
    'First_Name' => 'Eric',
    'Last_Name' => 'Cartman'
  }
)
```

#### Update a record

```ruby
# https://www.zoho.com/crm/developer/docs/api/v7/update-records.html

ZohoCrm::Record::UpdateService.call(
  module_name: 'Contacts',
  data: {
    'id' => '',
    'First_Name' => 'Eric Theodore'
  }
)
```

#### Upsert a record

```ruby
# https://www.zoho.com/crm/developer/docs/api/v7/upsert-records.html

ZohoCrm::Record::UpsertService.call(
  module_name: 'Contacts',
  data: {
    'Email' => 'eric.cartman@example.com',
    'First_Name' => 'Eric',
    'Last_Name' => 'Cartman Theodore 2nd'
  },
  duplicate_check_fields: ['Email']
)
```

#### Delete a record

```ruby
# https://www.zoho.com/crm/developer/docs/api/v7/delete-records.html

ZohoCrm::Record::DeleteService.call(module_name: 'Contacts', id: '')
```

</details>

<details>
<summary>Organization</summary>

### Organization

#### Get a organization

```ruby
# https://www.zoho.com/crm/developer/docs/api/v7/get-org-data.html

service = ZohoCrm::Organization::GetService.call
service.attributes
```

</details>

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kobusjoubert/zoho_crm.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
