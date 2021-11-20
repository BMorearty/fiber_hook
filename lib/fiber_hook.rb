# frozen_string_literal: true

require "fiber"
require_relative "fiber_hook/version"

# Allows you to hook fiber creation so you can call a method from the parent
# fiber immediately before any child fiber is created, return a value,
# and then call another method from inside the child fiber the first time the
# fiber is resumed, passing in the value that was returned from the first
# method.
module FiberHook
  class Error < StandardError; end

  class << self
    attr_reader :hooks
  end

  @hooks = {}
  @prev_id = 0

  # Add a hook and return its id.
  # @param new [Proc] Method to be called in parent fiber context when +Fiber.new+ is called.
  #   Takes no params. Its return value will be passed into +resume+.
  # @param resume [Proc] Method to be called in child fiber's context when +Fiber#resume+
  #   is called for the first time. Takes a single param: the value returned by +new+.
  # @return [Integer] The id of the newly-created hook. Can be passed in to +has?+ or
  #   +remove+.
  def self.add(new: nil, resume: nil)
    @prev_id += 1
    @hooks[@prev_id] = { new: new, resume: resume }
    @prev_id
  end

  # Is this hook id valid?
  def self.has?(hook_id)
    @hooks.key?(hook_id)
  end

  # Remove a hook by its id. Afterward, newly-created fibers won't have this hook.
  def self.remove(hook_id)
    value = @hooks.delete(hook_id)
    raise Error, "Hook #{hook_id} not found" unless value
  end

  # Class methods that will be added to +Fiber+.
  module ClassMethods
    def new(*args, &block)
      # In Fiber.new, call the :new methods of all the hooks. Save the results.
      values = FiberHook.hooks.transform_values { |hook| hook[:new]&.call }

      fiber_proc = proc do |*block_args|
        # In Fiber.resume, call the :resume methods of all the hooks.
        # Pass in the values returned by the :new methods.
        FiberHook.hooks.each { |id, hook| hook[:resume]&.call(values[id]) }
        # Then call the original fiber block.
        block.call(*block_args)
      end

      super(*args, &fiber_proc)
    end

    # @see FiberHook.add
    def hook(**options)
      FiberHook.add(**options)
    end

    # @see FiberHook.remove
    def unhook(hook_id)
      FiberHook.remove(hook_id)
    end

    # @see FiberHook.has?
    def hook?(hook_id)
      FiberHook.has?(hook_id)
    end
  end
end

Fiber.extend FiberHook::ClassMethods
