if ENV["S3_BUCKET"].present? && ENV["S3_SECRET_ACCESS_KEY"].present? &&
  ENV["S3_ACCESS_KEY_ID"].present?
  Paperclip::Attachment.default_options[:storage] = :s3
  Paperclip::Attachment.default_options[:s3_credentials] = {
    access_key_id: ENV["S3_ACCESS_KEY_ID"],
    secret_access_key: ENV["S3_SECRET_ACCESS_KEY"],
    bucket: ENV["S3_BUCKET"]
  }
  Paperclip::Attachment.default_options[:s3_protocol] = APP_CONFIG[:protocol]
else
  Rails.logger.info("no S3 environment variables to config Paperclip")
end
