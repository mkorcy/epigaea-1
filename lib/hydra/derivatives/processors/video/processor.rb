module Hydra::Derivatives::Processors
  module Video
    class Processor < Hydra::Derivatives::Processors::Processor
      include Ffmpeg

      class_attribute :config
      self.config = Config.new

      protected

        def options_for(format)
          input_options = ""
          output_options = "#{config.size_attributes(format)} #{codecs(format)}"

          if format == 'jpg'
            input_options += ' -itsoffset -2'
            output_options += ' -vframes 1 -an -f rawvideo'
          else
            output_options += " #{config.video_attributes} #{config.audio_attributes}"

            # Swap the m3u8 file out for our segment filename and attach the directive to the end.
            if format == 'm3u8'
              m3u8_path_pieces = directives[:url].split('/')
              m3u8_path_pieces[-1] = '%03d.ts'
              output_options += " -hls_segment_filename #{m3u8_path_pieces.join('/')}"
            end
          end

          { Ffmpeg::OUTPUT_OPTIONS => output_options, Ffmpeg::INPUT_OPTIONS => input_options }
        end

        def codecs(format)
          case format
          when 'mp4'
            config.mpeg4.codec
          when 'webm'
            config.webm.codec
          when "mkv"
            config.mkv.codec
          when "jpg"
            config.jpeg.codec
          when "m3u8"
            config.m3u8.codec
          else
            raise ArgumentError, "Unknown format `#{format}'"
          end
        end
    end
  end
end
