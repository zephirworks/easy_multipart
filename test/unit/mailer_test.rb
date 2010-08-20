require 'test_helper'

class MailerTest < ActionMailer::TestCase
  
  class TestMailer < ActionMailer::Base
    include EasyMultipart::Base
    
    def test
    end
  end
  
  test "sending a multipart email" do
    TestMailer.deliver_test
    assert_emails 1
    
    email = ActionMailer::Base.deliveries.first
    assert_equal    "multipart/alternative", email['content-type'].content_type
    assert_not_nil  email['content-type']['boundary']
  end
  
  test "a multipart email has parts in the correct order" do
    TestMailer.deliver_test
    
    email = ActionMailer::Base.deliveries.first
    assert_equal 2, email.parts.length
    
    plain_part = email.parts.first
    assert_equal    "text/plain", plain_part['content-type'].content_type
    assert_equal    "inline",     plain_part['content-disposition'].to_s
    
    html_part = email.parts.last
    assert_equal    "text/html",  html_part['content-type'].content_type
    assert_equal    "inline",     html_part['content-disposition'].to_s
  end
end
