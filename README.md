# FiberHook

With this gem you can hook into fiber creation to pass a 
value from the parent fiber to the child fiber. 

This is useful when you’ve got thread-local storage (which
is actually fiber-local) that you want also accessible from within
child fibers. It works without requiring that fibers go through
your own fiber-creation method, so that even fibers created inside
gems you don't own will work as expected. 

A potential use case is using the [Async](https://github.com/socketry/async)
gem with the [Falcon](https://github.com/socketry/falcon) server 
and you want to use [RequestStore](https://github.com/steveklabnik/request_store) 
for per-request storage. For this particular use case,
take a look at the
[request_store-fibers](https://github.com/BMorearty/request_store-fibers) gem.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fiber_hook'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install fiber_hook

## Usage

In this example you’re passing a thread-local `:request_store`
value from parent fiber to child fiber. They're sharing the
same object in memory but there's no risk of a race condition
because these are fibers, not threads.

```ruby
# `new` is a Proc that returns a value in the parent fiber context.
# `resume` is a Proc that takes that value as a param and runs
#   in the child fiber context.
Fiber.hook(
  new: -> { Thread.current[:request_store] },
  resume: ->(value) { Thread.current[:request_store] = value }
)
```

Need to remove a hook? Call `Fiber.unhook`:

```ruby
hook_id = Fiber.hook(...)
...
Fiber.unhook(hook_id)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/BMorearty/fiber_hook.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
