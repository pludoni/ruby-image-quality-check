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
end
