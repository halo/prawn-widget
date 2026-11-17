# frozen_string_literal: true

class RealDocumentComponent < Prawn::Component
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

    RealDocumentComponent.new.render_in(pdf) do |document|
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

  test '.render_in - with deprecated setters - writes a pdf file' do
    pdf = Prawn::Document.new

    capture_io do
      RealDocumentComponent.new.render_in(pdf) do |document|
        document.heading do
          pdf.text 'Hello'
        end
      end
    end

    path = File.join(@tmpdir, 'legacy.pdf')

    pdf.render_file(path)

    assert File.exist?(path)
    assert_equal '%PDF', File.read(path, 4)
  end
end
