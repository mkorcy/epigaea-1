RSpec.shared_examples 'a form with a transcription' do
  let(:file) { FakeTranscriptFile }
  it 'has a transcript_files hash' do
    expect(form.transcript_files("Video").is_a?(Hash)).to eq(true)
  end

  it 'can determine if a file is a transcript based on the mime type' do
    expect(form.transcript?(file, "Video")).to eq(true)
  end
end
