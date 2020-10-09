
# == Schema Information
#
# Table name: image_quality_check_results
#
#  id                :bigint(8)        not null, primary key
#  attachable_column :string(255)
#  attachable_type   :string(255)
#  quality           :integer
#  result            :json
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  attachable_id     :string(255)
#
# Indexes
#
#  index_image_quality_checks_on_all         (attachable_type,attachable_id,attachable_column) UNIQUE
#  index_image_quality_checks_on_attachable  (attachable_type,attachable_id)
#

class ImageQualityCheck::Result < ApplicationRecord
  self.table_name = 'image_quality_check_results'
  belongs_to :attachable, polymorphic: true

  def self.create_for_result(attachable, column, result)
    check = ImageQualityCheck::Result.where(attachable: some_organisation, attachable_column: :logo).first_or_initialize
    check.quality = result[:quality]
    check.result = {
      details: result[:details],
      messages: result[:message],
    }
    check.save!
  end
end
