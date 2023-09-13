require 'i18n'
# rubocop:disable Style/ClassVars,Metrics/BlockLength
module ImageQualityCheck::DSL
  def define_rules_for(klass, attachment:, &block)
    @rules ||= {}
    @rules[[klass.to_s, attachment.to_s]] = block
  end

  def rules_for(klass, attachment)
    rule = @rules[[klass.to_s, attachment.to_s]]
    unless rule
      raise NotImplemented, I18n.t("image_quality_check.dsl.no_qualities_defined_for", klass: (klass), attachment: (attachment))
    end
    @current_rule = []
    class_exec(&rule)
    @current_rule
  end

  def rule(name, weight: 1, &block)
    @current_rule << { name: name, block: block, weight: weight }
  end

  def preferred_formats_rule(weight: 1, **formats)
    rule I18n.t("image_quality_check.dsl.format"), weight: weight do |result, on_error|
      final_score = nil
      formats.each do |f, score|
        if result[:format].downcase.to_s == f.downcase.to_s
          final_score ||= score
        end
      end
      final_score ||= 0
      if final_score < 100
        message = I18n.t("image_quality_check.dsl.format_ist_nutzen_sie",
                         result_format: (result[:format]),
                         formats_keys_map_upcase_jo: (formats.keys.map(&:upcase).join(', ')))
        on_error.call(message)
      end
      final_score
    end
  end

  def preferred_size_rule(expected_width, expected_height, weight: 2)
    rule I18n.t("image_quality_check.dsl.gro_e"), weight: weight do |result, on_error|
      if result[:width] >= expected_width && result[:height] >= expected_height
        100
      else
        target = expected_width * expected_height
        current = result[:width] * result[:height]
        on_error.call(
          I18n.t("image_quality_check.dsl.gro_e_ist_x_px_achten_sie", result_width: (result[:width]), result_height: (result[:height]), expected_width: (expected_width), expected_height: (expected_height))
        )
        [current / target.to_f * 100, 90].min.round
      end
    end
  end
end
