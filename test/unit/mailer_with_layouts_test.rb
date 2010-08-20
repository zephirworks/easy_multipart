require 'test_helper'

class MailerWithLayoutsTest < ActionMailer::TestCase
  
  class TestMailer < ActionMailer::Base
    include EasyMultipart::Base
    layout "test_mailer"
    
    def test
    end
  end
  
  test "a multipart email uses the correct layouts for plain text" do
    TestMailer.deliver_test
    
    email       = ActionMailer::Base.deliveries.first
    plain_part  = email.parts.first
    assert_equal "~~~ Some text header ~~~\n\n* This is a test!\n\n~~~ Some text footer ~~~\n",
                  plain_part.body
  end
  
  test "a multipart email uses the correct layouts for HTML text" do
    TestMailer.deliver_test
    
    email       = ActionMailer::Base.deliveries.first
    html_part  = email.parts.last
    assert_equal "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\"\n" +
                 "  \"http://www.w3.org/TR/html4/strict.dtd\">\n<html>\n" +
                 "<head></head>\n<body>\n  <h1>This is a test!</h1>\n</body>\n</html>",
                  html_part.body
  end
end
