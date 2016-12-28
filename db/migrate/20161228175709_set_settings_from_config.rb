class SetSettingsFromConfig < ActiveRecord::Migration[5.0]
  def change
  end

  def data
    Setting.reset_column_information
    Rails.logger.info 'Seed Settings with features/secrets'
    s = Rails.application.secrets
    Setting['aws.access_key_id'] = s.fog['aws_access_key_id']
    Setting['aws.access_key_secret'] = s.fog['aws_secret_access_key']
    Setting['aws.account_id'] = s.aws_account_id
    Setting['aws.region'] = s.fog['region']
    Setting['aws.bucket'] = s.fog['bucked']
    Setting['aws.acl'] = 'public-read'
    Setting['rekognition.enabled'] = true
    Setting['rekognition.labels.max_labels'] = 20
    Setting['rekognition.labels.min_confidence'] = 40
    Setting['rekognition.faces.enabled'] = true
    Setting['rekognition.faces.rekognition_collection'] = s.rekognition_collection
    Setting['rekognition.faces.auto_assign.enabled'] = true
    Setting['rekognition.faces.auto_assign.max_faces'] = 15
    Setting['rekognition.faces.auto_assign.min_existing_faces'] = 10
    Setting['rekognition.faces.auto_assign.threshold'] = 85
  end
end
