RSpec.describe ImageQualityCheck do
  specify 'jpg good quality' do
    result = ImageQualityCheck.analyze("spec/files/person1.jpg")
    expect(result[:blur]).to be_kind_of(Hash)
  end

  specify 'jpg small quality' do
    result = ImageQualityCheck.analyze("spec/files/pludoni.jpg")
    expect(result[:blur]).to be_kind_of(Hash)
  end

  specify 'png' do
    result = ImageQualityCheck.analyze("spec/files/pludoni.png")
    expect(result[:background_is_transparent]).to be == true
    expect(result[:blur]).to be_kind_of(Hash)
  end

  specify 'white = NaN' do
    result = ImageQualityCheck.analyze("spec/files/white.jpg")
    expect(result[:blur]).to be_kind_of(Hash)
  end

  specify 'gif' do
    result = ImageQualityCheck.analyze("spec/files/logo.gif")
    expect(result).to be_kind_of(Hash)
  end

  specify 'determine quality' do
    class SomeClass
      def attachment
      end
    end
    ImageQualityCheck.define_rules_for(SomeClass, attachment: :attachment) do
      preferred_formats_rule({jpeg: 100})
      preferred_size_rule(500, 500)
    end
    quality = ImageQualityCheck::DetermineQuality.new(SomeClass.new, :attachment)

    expect(quality).to receive(:read!) do |tmp_file|
      FileUtils.cp('spec/files/logo.png', tmp_file.path)
      true
    end
    result = quality.run
    expect(result[:details][:width]).to be > 0
    expect(result[:messages].length).to be == 2
    expect(result[:quality]).to be < 100
  end
end
