require "image_quality/version"
require 'shellwords'
require 'json'
require 'open3'

module ImageQuality
  def self.analyze(path_to_image)
    out = `convert #{Shellwords.escape path_to_image} json:`
    json = JSON.parse(out)['image']
    {
      format: json['format'].downcase,
      mime_type: json['mimeType'],
      width: json.dig('geometry', 'width'),
      height: json.dig('geometry', 'height'),
      quality: json['quality'],
      blur: blur_detect(path_to_image)
    }
  end

  def self.blur_detect(path_to_image)
    script = File.join(File.dirname(__FILE__), '..', 'exe', 'image_quality_blur')
    out, err, value = Open3.capture3("#{script} #{Shellwords.escape(path_to_image)}")
    if value.success?
      JSON.parse(out.gsub('NaN', '0')).
        delete_if { |k, _| k == 'inputPath' }.
        map { |k, v| [k.to_sym, v] }.
        to_h
    else
      {
        error: err.to_s
      }
    end
  end
end
