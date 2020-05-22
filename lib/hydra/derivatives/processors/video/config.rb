module Hydra::Derivatives::Processors::Video
  class Config
    attr_writer :video_bitrate, :video_attributes, :size_attributes, :audio_attributes

    def video_bitrate
      @video_bitrate ||= default_video_bitrate
    end

    def video_attributes
      @video_attributes ||= default_video_attributes
    end

    def size_attributes(format)
      if format == "jpg"
        @image_size_attributes ||= default_image_size_attributes
      else
        @video_size_attributes ||= default_video_size_attributes
      end
    end

    def audio_attributes
      @audio_attributes ||= default_audio_attributes
    end

    def mpeg4
      audio_encoder = Hydra::Derivatives::AudioEncoder.new
      @mpeg4 ||= CodecConfig.new("-vcodec libx264 -max_muxing_queue_size 1024 -acodec #{audio_encoder.audio_encoder}")
    end

    def webm
      @webm ||= CodecConfig.new('-vcodec libvpx -max_muxing_queue_size 1024 -acodec libvorbis')
    end

    def mkv
      @mkv ||= CodecConfig.new('-vcodec ffv1')
    end

    def jpeg
      @jpeg ||= CodecConfig.new('-vcodec mjpeg')
    end

    class CodecConfig
      attr_writer :codec

      def initialize(default)
        @codec = default
      end

      attr_reader :codec
    end

    protected

      def default_video_bitrate
        # '345k' Unused
      end

      def default_video_attributes
        "-g 30"
      end

      def default_image_size_attributes
        "-s 320x240"
      end

      ##
      # min(1080,ih) means use 1080 or original height, whichever is smaller
      # -2 is match width to height if changing height and preserve aspect ratio
      def default_video_size_attributes
        "-vf \"scale=-2:'min(1080,ih)'\""
      end

      def default_audio_attributes
        "-ac 2 -ab 96k -ar 44100"
      end
  end
end
