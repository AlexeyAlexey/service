# frozen_string_literal: true

RSpec.describe Service do
  it "has a version number" do
    expect(Service::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end