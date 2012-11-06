require "selenium-webdriver"


puts "-> If the local server isn't running, this isn't going to work!"
puts "-> Running these tests triggers a local rebuild."

%x[ruby build.rb]


describe "Integration Tests" do
  before(:all) do
    @driver = Selenium::WebDriver.for :firefox
    @driver.navigate.to "http://localhost:8080/testing-data"
  end

  it "shows the expected heading" do
    @driver["document-title"].displayed?.should eq true
  end
  after(:all) do
    @driver.close
  end

end
