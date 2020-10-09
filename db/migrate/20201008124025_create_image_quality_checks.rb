class CreateImageQualityChecks < ActiveRecord::Migration[5.2]
  def change
    create_table :image_quality_check_results do |t|
      t.string :attachable_type
      t.string :attachable_id
      t.string :attachable_column
      t.json :result
      t.integer :quality

      t.timestamps
      t.index [:attachable_type, :attachable_id], name: 'index_image_quality_checks_on_attachable'
      t.index [:attachable_type, :attachable_id, :attachable_column], unique: true, name: 'index_image_quality_checks_on_all'
    end
  end
end
