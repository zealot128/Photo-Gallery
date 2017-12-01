class MigrateLabels < ActiveRecord::Migration[5.1]
  def change
  end

  def data
    t = I18n.t('aws_labels', locale: 'en').zip(I18n.t('aws_labels', locale: 'de')).to_h
    t.each do |k, v|
      label = ImageLabel.where(name: k).first_or_initialize
      label.name_de = v
      label.save!
    end
  end
end
