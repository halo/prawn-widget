# frozen_string_literal: true

class RealDocumentWidget < Prawn::Widget
  renders_one :heading
  renders_many :paragraphs

  def call
    pdf.text 'Document'

    heading&.draw
    paragraphs.each(&:draw)
  end
end

class PdfGenerationTest < Megatest::Test
  setup do
    @tmpdir = File.expand_path('../../tmp', __dir__)

    FileUtils.mkdir_p(@tmpdir)
  end

  test '.render_in - with a real document - writes a pdf file' do
    pdf = Prawn::Document.new

    RealDocumentWidget.new.render_in(pdf) do |document|
      document.with_heading do
        pdf.text 'Hello'
      end

      document.with_paragraph do
        pdf.text 'First'
      end

      document.with_paragraph do
        pdf.text 'Second'
      end
    end

    path = File.join(@tmpdir, 'document.pdf')

    pdf.render_file(path)

    assert File.exist?(path)
    assert File.size(path).positive?
    assert_equal '%PDF', File.read(path, 4)
    assert_equal 1, pdf.page_count
  end
end
