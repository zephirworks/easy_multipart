require 'test_helper'
require 'easy_multipart'

class EasyMultipartMailerTest < ActionMailer::TestCase
  
  class TestMailer < ActionMailer::Base
    include EasyMultipart::Base
    layout "test_mailer"
    
    def test
      easy_multipart
    end
    
    def text_plain_only
      easy_multipart
    end
    
    def test_with_related
      easy_multipart
    end
    
    def test_with_arguments
      easy_multipart :body => {:value => 42}
    end
    
    def test_with_related_image(image_options = {})
      easy_multipart :body => {:image_options => image_options}
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
    assert_equal  2,                    email.parts.length
    
    plain_part = email.parts.first
    assert_equal  "text/plain",         plain_part['content-type'].content_type
    assert_equal  "inline",             plain_part['content-disposition'].to_s
    
    html_part = email.parts.last
    assert_equal  "text/html",          html_part['content-type'].content_type
    assert_equal  "inline",             html_part['content-disposition'].to_s
  end
  
  test "sending an email with text/plain only" do
    TestMailer.deliver_text_plain_only
    assert_emails 1
    
    email = ActionMailer::Base.deliveries.first
    assert_equal    "multipart/alternative", email['content-type'].content_type
    assert_not_nil  email['content-type']['boundary']
    assert_equal  1,                    email.parts.length
    
    plain_part = email.parts.first
    assert_equal  "text/plain",         plain_part['content-type'].content_type
    assert_equal  "inline",             plain_part['content-disposition'].to_s
  end
  
  test "a multipart email with related parts has parts in the correct order" do
    TestMailer.deliver_test_with_related
    
    email = ActionMailer::Base.deliveries.first
    assert_equal  2,                    email.parts.length
    
    plain_part = email.parts.first
    assert_equal  "text/plain",         plain_part['content-type'].content_type
    assert_equal  "inline",             plain_part['content-disposition'].to_s
    
    multipart = email.parts.last
    assert_equal  "multipart/related",  multipart['content-type'].content_type
    assert_equal  2,                    multipart.parts.length
    
    html_part = multipart.parts.first
    assert_equal  "text/html",          html_part['content-type'].content_type
    assert_equal  "inline",             html_part['content-disposition'].to_s
    
    assert_match /<img src="cid:abcd1234"\s*\/>/,    html_part.body
    
    png_part = multipart.parts.last
    assert_equal  "image/png",          png_part['content-type'].content_type
    assert_equal  "<abcd1234>",         png_part['content-id'].to_s
  end
  
  test "a multipart email with a related image has the expected parts" do
    TestMailer.deliver_test_with_related_image
    
    email = ActionMailer::Base.deliveries.first
    assert_equal  1,                    email.parts.length
    
    multipart = email.parts.last
    assert_equal  "multipart/related",  multipart['content-type'].content_type
    assert_equal  2,                    multipart.parts.length
    
    html_part = multipart.parts.first
    assert_equal  "text/html",          html_part['content-type'].content_type
    assert_equal  "inline",             html_part['content-disposition'].to_s
    
    png_part = multipart.parts.last
    assert_equal  "image/png",          png_part['content-type'].content_type
    assert_equal  "<image.png>",        png_part['content-id'].to_s
  end
  
  test "a multipart email with arguments interpolates them" do
    TestMailer.deliver_test_with_arguments
    
    email = ActionMailer::Base.deliveries.first
    assert_equal  2,                    email.parts.length
    
    plain_part = email.parts.first
    assert_match /-42-/,                plain_part.body
    
    html_part = email.parts.last
    assert_match /<span>42<\/span>/,    html_part.body
  end
  
  test "a multipart email with a related image with options passes them to image_tag" do
    TestMailer.deliver_test_with_related_image(:alt => 'test image')
    
    email = ActionMailer::Base.deliveries.first
    assert_equal  1,                    email.parts.length
    
    multipart = email.parts.last
    html_part = multipart.parts.first
    assert_equal  "text/html",          html_part['content-type'].content_type
    assert_equal  "inline",             html_part['content-disposition'].to_s
    
    assert_match /<img[^>]+alt=".+?"[^>]+>/,    html_part.body
  end
end
