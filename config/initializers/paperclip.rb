# Paperclip.interpolates :date do |attachment, style|
#   attachment.instance.shot_at.to_date
# end


# module Paperclip
#   class AutoOrient < Paperclip::Processor
#     def initialize(file, options = {}, *args)
#       @file = file
#     end

#     def make( *args )
#       dst = Tempfile.new([@basename, @format].compact.join("."))
#       dst.binmode

#       Paperclip.run('convert',"#{File.expand_path(@file.path)} -auto-orient #{File.expand_path(dst.path)}")

#       return dst
#     end
#   end
# end
