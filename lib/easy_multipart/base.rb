require 'easy_multipart/helper'

module EasyMultipart #:nodoc:
  # This module enables EasyMultipart functionality for the mailers it is
  # included in.
  #
  # ==== Examples
  # Import easy_mailer in one mailer:
  #
  #   class MyMailer
  #     import EasyMultipart::Base
  #   end
  #
  # Import easy_mailer in all the mailers of a Rails application:
  #
  #   ActiveMailer::Base.extend EasyMultipart::Base
  #
  module Base
    
    def self.included(klass) #:nodoc:
      klass.helper EasyMultipart::Helper
    end
  
  protected
    # Prepares the content of a multipart email.
    # You can pass a +options+ hash with one key:
    #
    # * <tt>body</tt> - a hash which generates an instance variable named
    #   after each key in the hash containing the value that that key points to.
    def easy_multipart(options = {}, &block)
      content_type 'multipart/alternative'
      TMail::HeaderField::FNAME_TO_CLASS.delete 'content-id'
      
      if options.has_key?(:body)
        body options.delete(:body)
      end
      
      add_plain_part
      add_html_part
    end
    
    def add_plain_part #:nodoc:
      template = find_template_for("text.plain")
      return unless template
      
      part :content_type => "text/plain",
            :body => render_message(template, @body)
    end
    
    def add_html_part #:nodoc:
      template = find_template_for("text.html")
      return unless template
      
      @related = {}
      body = render_message(template, @body)
      
      if @related.empty?
        part :content_type => "text/html",
              :body => body
        return
      end
      
      part :content_type => 'multipart/related' do |related|
        related.part :content_type => "text/html",
                      :body => body
        
        @related.each_pair do |content_id, img|
          related.part(:content_type => img[0],
                        :headers => {'Content-ID' => format_content_id(content_id)}) do |image|
            img[1].call(image)
          end
        end
      end
    end
    
    def find_template_for(format) #:nodoc:
      Dir.glob("#{template_path}/#{@template}.*").select do |path|
        template = template_root["#{mailer_name}/#{File.basename(path)}"]
        return template if template.format == format
      end
      nil
    end
    
    # XXX This should generate a globally-unique Content-Id.
    def format_content_id(content_id) #:nodoc:
      "<#{content_id}>"
    end
  end
end
