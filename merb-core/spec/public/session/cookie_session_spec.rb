require File.join(File.dirname(__FILE__), "spec_helper")
startup_merb(:session_store => "cookie",
             :session_secret_key => "session-secret-key-here",
             :default_cookie_domain => '.localhost.com')
require File.join(File.dirname(__FILE__), "controllers", "sessions")

describe Merb::CookieSession do
  
  before do 
    @session_class = Merb::CookieSession
    @session = @session_class.generate
  end
  
  it_should_behave_like "All session-store backends"
  
  it "should have a session_store_type class attribute" do
    @session.class.session_store_type.should == :cookie
  end
  
end

describe Merb::CookieSession, "mixed into Merb::Controller" do
  include Merb::Test::CookiesHelper
  
  before(:all) { @controller_klass = Merb::Test::Fixtures::Controllers::SessionsController }
  
  it "should represent the controller session" do
    controller = dispatch_to(@controller_klass, :index)
    controller.body.should == "cookie"
    controller.request.session.should be_kind_of(Merb::CookieSession)
  end
  
  it "should store and retrieve session data" do
    with_cookies(@controller_klass) do
      controller = dispatch_to(@controller_klass, :index, :foo => "cookie")
      controller.request.session[:foo].should == "cookie"
    
      controller = dispatch_to(@controller_klass, :retrieve)
      controller.request.session[:foo].should == "cookie"
    end
  end
  
  it "should allow regeneration of the session" do
    with_cookies(@controller_klass) do
      controller = dispatch_to(@controller_klass, :index, :foo => "cookie")
      controller = dispatch_to(@controller_klass, :regenerate)
      controller = dispatch_to(@controller_klass, :retrieve)
      controller.request.session[:foo].should == "cookie"
    end    
  end
    
  it "shouldn't allow tampering with cookie data" do
    with_cookies(@controller_klass) do |cookie_jar|
      controller = dispatch_to(@controller_klass, :index, :foo => "cookie")
      cookie_data, cookie_checksum = controller.cookies[Merb::Request._session_id_key].split('--')
      cookie_data = 'tampered-with-data'
      cookie_jar[Merb::Request._session_id_key] = "#{cookie_data}--#{cookie_checksum}"
      controller = dispatch_to(@controller_klass, :retrieve)
      lambda { controller.request.session }.should raise_error(Merb::CookieSession::TamperedWithCookie)
    end
  end
    
  it "shouldn't allow tampering with cookie fingerprints" do
    with_cookies(@controller_klass) do |cookie_jar|
      controller = dispatch_to(@controller_klass, :index, :foo => "cookie")
      cookie_data, cookie_checksum = controller.cookies[Merb::Request._session_id_key].split('--')
      cookie_checksum = 'tampered-with-checksum'
      cookie_jar[Merb::Request._session_id_key] = "#{cookie_data}--#{cookie_checksum}"
      controller = dispatch_to(@controller_klass, :retrieve)
      lambda { controller.request.session }.should raise_error(Merb::CookieSession::TamperedWithCookie)
    end
  end

  it "should set cookie domain to default_cookie_domain if set" do
    controller = dispatch_to(@controller_klass, :index, :foo => "cookie")
    cookie = extract_cookies(controller.headers).sort[0]
    cookie.should match(/_session_id=/)
    cookie.should match(/domain=.localhost.com/)
  end
  
end
