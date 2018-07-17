Factory.define :authentication do |f|
  f.association :user
  f.provider 'fake_provider'
  f.uid 'fake_uid'
end
