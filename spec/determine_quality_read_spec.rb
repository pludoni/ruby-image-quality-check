require 'spec_helper'
require 'tempfile'
require 'fileutils'

RSpec.describe ImageQualityCheck::DetermineQuality, '#read!' do
  let(:tmp_file) { Tempfile.new(['test_image', '.jpg']) }
  let(:source_file) { 'spec/files/pludoni.jpg' }
  let(:source_content) { File.binread(source_file) }
  let(:blob_key) { 'test-blob-key' }

  # Fake ActiveStorage::Attached::One so class.to_s matches the case/when
  let(:attached_class) do
    Class.new do
      def self.to_s = 'ActiveStorage::Attached::One'
      attr_accessor :blob, :_attached, :_download_content

      def attached? = _attached
      def download = _download_content
    end
  end

  let(:blob) { double('blob', key: blob_key, service: service) }
  let(:column) do
    col = attached_class.new
    col.blob = blob
    col._attached = true
    col._download_content = source_content
    col
  end
  let(:model) do
    m = double('model', attachment: column)
    allow(m.class).to receive(:to_s).and_return('TestModel')
    m
  end

  after { tmp_file.close! }

  context 'with DiskService (supports path_for)' do
    let(:service) do
      path = source_file
      svc = Object.new
      svc.define_singleton_method(:path_for) { |_key| path }
      svc
    end

    it 'copies the file from disk without downloading' do
      quality = ImageQualityCheck::DetermineQuality.new(model, :attachment)
      result = quality.send(:read!, tmp_file)

      expect(result).to be true
      expect(File.binread(tmp_file.path)).to eq source_content
    end
  end

  context 'with S3Service (no path_for)' do
    let(:service) { Object.new }

    it 'downloads the file via ActiveStorage' do
      quality = ImageQualityCheck::DetermineQuality.new(model, :attachment)
      result = quality.send(:read!, tmp_file)

      expect(result).to be true
      expect(File.binread(tmp_file.path)).to eq source_content
    end
  end

  context 'with MirrorService (responds to path_for but delegates to S3)' do
    let(:service) do
      svc = Object.new
      svc.define_singleton_method(:path_for) do |key|
        raise NoMethodError, "undefined method `path_for' for an instance of ActiveStorage::Service::S3Service"
      end
      svc
    end

    it 'falls back to download when path_for raises NoMethodError' do
      quality = ImageQualityCheck::DetermineQuality.new(model, :attachment)
      result = quality.send(:read!, tmp_file)

      expect(result).to be true
      expect(File.binread(tmp_file.path)).to eq source_content
    end
  end

  context 'with no blob attached' do
    let(:service) { Object.new }

    it 'returns false when blob is nil' do
      column.blob = nil

      quality = ImageQualityCheck::DetermineQuality.new(model, :attachment)
      result = quality.send(:read!, tmp_file)

      expect(result).to be false
    end

    it 'returns false when not attached' do
      column._attached = false

      quality = ImageQualityCheck::DetermineQuality.new(model, :attachment)
      result = quality.send(:read!, tmp_file)

      expect(result).to be false
    end
  end
end
