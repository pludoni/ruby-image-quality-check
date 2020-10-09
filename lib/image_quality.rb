require "image_quality/version"
require 'image_quality/dsl'
require 'image_quality/determine_quality'
require 'shellwords'
require 'json'
require 'open3'

if defined?(Rails)
  binding.pry
  config.i18n.railties_load_path << paths["config/locales"]
else
  require 'i18n'
  I18n.load_path << Dir[File.expand_path("config/locales") + "/*.yml"]
  I18n.default_locale ||= :en
  require 'pry'
  binding.pry
end

module ImageQuality
  extend ImageQuality::DSL

  def self.determine_quality(model, attachment, &block)
    ImageQuality::DetermineQuality.run(model, attachment, &block)
  end

  def self.analyze(path_to_image)
    out = `convert #{Shellwords.escape path_to_image} json:`
    json = JSON.parse(out)['image']
    {
      format: json['format'].downcase,
      mime_type: json['mimeType'],
      width: json.dig('geometry', 'width'),
      height: json.dig('geometry', 'height'),
      quality: json['quality'],
      blur: blur_detect(path_to_image).map { |k, v| [ k.to_sym, v ] }.to_h
    }
  end

  def self.blur_detect(path_to_image)
    script = File.join(File.dirname(__FILE__), '..', 'exe', 'image_quality_blur')
    out, err, value = Open3.capture3("#{script} #{Shellwords.escape(path_to_image)}")
    if value.success?
      JSON.parse(out.gsub('NaN', '0'))
    else
      if out[/^\{/]
        JSON.parse(out)
      else
        {
          error: err.to_s,
          out: out.to_s
        }
      end
    end
  end
end
