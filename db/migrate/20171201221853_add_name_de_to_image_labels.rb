class AddNameDeToImageLabels < ActiveRecord::Migration[5.1]
  def change
    add_column :image_labels, :name_de, :string
  end
end
