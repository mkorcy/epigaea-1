require 'byebug'

module Tufts
  CONFIG = YAML.load_file(Rails.root.join('config', 'pdf_pages.yml'))[Rails.env]

  class PdfPages
    def initialize
      log_file = File.open(Rails.root.join('log', 'pngizer.log'), 'a')
      log_file.sync = true # causes each log message to be flushed immediately
      @logger = Logger.new(log_file)
      @pages_root = CONFIG['pages_root']
    end

    def convert_object_to_png(object)
      pid = object.id
      return success if pid.nil?
      obj = ActiveFedora::Base.find(pid)
      file_set = obj.file_sets[0]
      convert_file_set_to_png(file_set)
    end

    def convert_file_set_to_png(file_set)
      success = false
      return success if file_set.nil?

      begin
        success = process_file_set(file_set)
      rescue Magick::ImageMagickError => ex
        @logger.error($PROGRAM_NAME + ex.message)
      rescue SystemCallError => ex
        @logger.error($PROGRAM_NAME + ' I/O error: ' + ex.message)
      rescue StandardError => ex
        @logger.error($PROGRAM_NAME + ' error: ' + ex.message)
      end

      success
    end

    private

      def process_file_set(file_set)
        initialize_obj_directory(file_set)
        write_pdf_locally(file_set)
        pdf_path = get_local_pdf_path(file_set).to_s
        write_metadata_file(file_set, pdf_path)
        write_pages(file_set, pdf_path)
        true
      end

      def write_blank_page(file_set, pdf_pages)
        @logger.info("Writing Blank Page...")
        png = ChunkyPNG::Image.new(page_width(pdf_pages).to_i, page_height(pdf_pages).to_i, ChunkyPNG::Color::TRANSPARENT)
        png_path = get_png_path(file_set, 0)
        png.save(png_path, interlace: true)
        @logger.info("Done Writing Blank Page...")
      end

      def write_pages(file_set, pdf_path)
        pdf_pages = Magick::Image.read(pdf_path + page_suffix(0)) { self.density = '150x150' }
        write_blank_page(file_set, pdf_pages)
        count = page_count(pdf_path).to_i
        (0..(count - 1)).each do |pdf_page_number|
          pdf_page = Magick::Image.read(pdf_path + page_suffix(pdf_page_number))
          # pdf_pages.each do |pdf_page|
          png_path = get_png_path(file_set, (pdf_page_number.to_i + 1).to_s)
          @logger.info('Writing ' + png_path.to_s)
          pdf_page[0].write(png_path) { self.quality = 100 }
          pdf_page[0].destroy! # this is important - without it RMagick can occasionally be left in a state that causes subsequent failures
        end

        @logger.info('Successfully completed ' + file_set.id)
      end

      def page_suffix(number)
        str_num = number.to_s
        "[" + str_num + "]"
      end

      def initialize_obj_directory(file_set)
        FileUtils.mkdir_p File.join(@pages_root, file_set.id)
      end

      def write_metadata_file(file_set, pdf_path)
        pdf_pages = Magick::Image.read(pdf_path + "[0]") { self.density = '150x150' }
        @logger.info('Found ' + (page_count(pdf_path).to_i + 1).to_s + ' pages (' + page_width(pdf_pages) + ' x ' + page_height(pdf_pages) + ').')
        meta_path = File.join(@pages_root, file_set.id, 'book.json')
        json = create_meta_json(pdf_pages, pdf_path)
        @logger.info('Writing ' + json + ' to ' + meta_path + '.')
        File.open(meta_path, 'w') { |file| file.puts(json) }
      end

      def create_meta_json(pdf_pages, pdf_path)
        '{"page_width":"' + page_width(pdf_pages) + '","page_height":"' + page_height(pdf_pages) + '","page_count":"' + (page_count(pdf_path).to_i + 1).to_s + '"}'
      end

      def page_height(pdf_pages)
        pdf_pages[0].rows.to_s
      end

      def page_width(pdf_pages)
        pdf_pages[0].columns.to_s
      end

      def page_count(pdf_path)
        reader = PDF::Reader.new(pdf_path)
        reader.page_count.to_s
      end

      def get_png_path(file_set, page_number)
        target_filename = file_set.id + '_' + page_number.to_s + ".png"
        File.join(@pages_root, file_set.id, target_filename)
      end

      def get_local_pdf_path(file_set)
        target_filename = file_set.id + ".pdf"
        File.join(@pages_root, file_set.id, target_filename)
      end

      def write_pdf_locally(file_set)
        record = File.new(get_local_pdf_path(file_set), 'wb')

        @logger.info "Writing fileset to #{record}"
        record.write file_set.original_file.content
        record.flush
        record.close
      end
  end
end
