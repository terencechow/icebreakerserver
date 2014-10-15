module Paperclip
  class Cropper < Thumbnail
    def initialize(file, options = {}, attachment = nil)
      super
      @current_geometry.width = target.crop_w
      @current_geometry.height = target.crop_h
    end
    def target
      @attachment.instance
    end
    def optio
      @options
    end
    def fil
      @file
    end
    def transformation_command
      puts target.inspect
      puts optio.inspect
      puts fil.inspect
      puts "what was it!???"
      crop_command = ["-crop","#{target.crop_w}x#{target.crop_h}+#{target.crop_x}+#{target.crop_y}"]
      crop_command + super
    end
  end
end