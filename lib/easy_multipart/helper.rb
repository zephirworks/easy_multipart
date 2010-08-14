module EasyMultipart #:nodoc:
  # This module provides methods for generating HTML body parts that include
  # embedded images.
  module Helper
    # Returns an HTML image tag for the +source+. The +source+ can be a full
    # path or a file that exists in your public images directory.
    # Alternatively, it can be a hash with these mandatory keys:
    #
    # * <tt>:body</tt> - An object representing the image content. Any kind of
    #   object can be used, as long as it responds to :to_s.
    # * <tt>:content_id</tt> - A string that uniquely identifies the image
    #   within the current document.
    #
    # ==== Options
    # You can add HTML attributes using the +image_options+. You can pass
    # any option accepted by +image_tag+.
    #
    # You can pass additional options through +related_options+:
    #
    # * <tt>:content_type</tt> - The value to use for the Content-Type
    #   MIME header. If not provided it defaults to 'image/png'.
    # * <tt>:transfer_encoding</tt> - The value to use for the
    #   Transfer-Encoding MIME header. If not provided it defaults
    #   to 'base64'. Unless you have special requirements, you should not
    #   provide a value for this key.
    # * <tt>:content_disposition</tt> - The value to use for the
    #   Content-Disposition MIME header. If not provided it defaults to
    #   not generating a Content-Disposition header.
    def related_image_tag(source, image_options = {}, related_options = {})
      related_options.reverse_merge! :content_type => 'image/png',
                                      :transfer_encoding => 'base64'
      
      if source.is_a?(Hash)
        unless source.has_key?(:content_id)
          raise "You must specify a :content_id if you provide a :body"
        end
        
        content_id  = source[:content_id]
        source      = source[:body].to_s
      else
        if source.first != '/'
          assets_dir  = defined?(Rails.public_path) ? Rails.public_path : "public"
          source      = File.join(assets_dir, "images", source)
        end
        
        content_id  = File.basename(source)
        source      = File.read(source)
      end
      content_id = normalize_content_id(content_id)
      
      @related[content_id] = [related_options[:content_type], lambda do |image|
        image.body                = source
        image.transfer_encoding   = related_options[:transfer_encoding]
        image.content_disposition = related_options[:content_disposition] # default is none
      end]
      
      @template.tag(:img, image_options.merge(:src => "cid:#{content_id}"))
    end
    
    # XXX We should use a method in EasyMultipart::Base so we can share code
    # with format_content_id.
    def normalize_content_id(content_id) #:nodoc:
      "#{content_id}"
    end
  end
end
