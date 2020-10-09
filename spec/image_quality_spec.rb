RSpec.describe ImageQuality do
  specify 'jpg good quality' do
    result = ImageQuality.analyze("spec/files/person1.jpg")
    expect(result[:blur]).to be_kind_of(Hash)
  end

  specify 'jpg small quality' do
    result = ImageQuality.analyze("spec/files/pludoni.jpg")
    expect(result[:blur]).to be_kind_of(Hash)
  end

  specify 'png' do
    result = ImageQuality.analyze("spec/files/logo.png")
    expect(result[:blur]).to be_kind_of(Hash)
  end

  specify 'white = NaN' do
    result = ImageQuality.analyze("spec/files/white.jpg")
    expect(result[:blur]).to be_kind_of(Hash)
  end

  specify 'determine quality' do
    class SomeClass
      def attachment
      end
    end
    ImageQuality.define_rules_for(SomeClass, attachment: :attachment) do
      preferred_formats_rule(jpeg: 100)
      preferred_size_rule(500, 500)
    end
    quality = ImageQuality::DetermineQuality.new(SomeClass.new, :attachment)

    expect(quality).to receive(:read!) do |tmp_file|
      FileUtils.cp('spec/files/logo.png', tmp_file.path)
      true
    end
    result = quality.run
    expect(result[:width]).to be_present
    expect(result[:quality]).to be < 100
  end
end
