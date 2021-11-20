# frozen_string_literal: true

RSpec.describe Fiber do
  describe "#hook" do
    it "hooks fiber creation" do
      hook_id = Fiber.hook(
        new: -> { Thread.current[:mouse] },
        resume: ->(value) { Thread.current[:mouse] = value }
      )
      Thread.current[:mouse] = { first: "Mickey" }
      result = Fiber.new { Thread.current[:mouse][:first] }.resume
      expect(result).to eq("Mickey")
    ensure
      Fiber.unhook(hook_id)
    end
  end

  describe "#unhook" do
    it "removes the hook" do
      hook_id = Fiber.hook(
        new: -> { Thread.current[:mouse] },
        resume: ->(value) { Thread.current[:mouse] = value }
      )
      Thread.current[:mouse] = { first: "Mickey" }

      # Hook is in place.
      result = Fiber.new { Thread.current[:mouse][:first] }.resume
      expect(result).to eq("Mickey")

      Fiber.unhook(hook_id)

      # Hook is no longer in place.
      result = Fiber.new { Thread.current[:mouse]&.[](:first) }.resume
      expect(result).to be_nil
    ensure
      Fiber.unhook(hook_id) if Fiber.hook?(hook_id)
    end
  end
end
