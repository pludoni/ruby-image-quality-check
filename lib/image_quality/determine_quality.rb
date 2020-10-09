require 'i18n'

class ImageQuality::DetermineQuality
  def self.run(model, column_name)
    new(model, column_name).run
  end

  def initialize(model, column_name)
    @model = model
    @column_name = column_name
    @column = model.send(column_name)
    @messages = []
  end

  def run(&block)
    tmp_file = Tempfile.new(['image_quality'])
    unless read!(tmp_file)
      result = {
        quality: 0,
        details: {},
        messages: [{ name: I18n.t('image_quality.not_found'), quality: 0 }]
      }
      yield(result) if block_given?
      return result
    end

    @analyse_result = ImageQuality.analyze(tmp_file.path)
    result = {
      quality: determine_quality,
      details: @analyse_result,
      messages: @messages,
    }
    yield(result) if block_given?
    result
  end

  private

  def determine_quality
    qualities = []
    sum_of_weights = 0
    ImageQuality.rules_for(@model.class, @column_name).each do |qq|
      error = nil
      on_error = ->(msg) { error = msg }
      result = instance_exec(@analyse_result, on_error, &qq[:block])
      @messages << {
        name: qq[:name],
        quality: result,
        message: error
      }
      if result
        qualities << result * qq[:weight]
        sum_of_weights += qq[:weight]
      end
    end

    (qualities.sum / sum_of_weights.to_f).round
  end

  def read!(tmp_file)
    case @column.class.to_s
    when "Paperclip::Attachment"
      if !@column.path || !File.exist?(@column.path)
        false
      else
        FileUtils.cp(@column.path, tmp_file.path)
        true
      end
    else
      raise NotImplementedError, @column.class
    end
  end
end
