require File.expand_path('../../spec_helper', __FILE__)

describe Image do
  let(:dimensions)  { double(:width  => 100, :height => 100) }
  let(:license)     { mock_model(CommonsLicense, :code => 'CC-BY') }
  let(:user)        { mock_model(User, :login=>"testuser") }
  let(:img_filename){ "testing_file_name" }
  let(:name)        { "testing" }

  let(:image_file) { fixture_file_upload(Rails.root.join("spec/fixtures/images/rails.png"), "image/png") }

  let(:attributes) do
    {
      'license' => license,
      'name' => name,
      'user' => user,
      'image' => image_file
    }
  end

  subject { Image.create(attributes) }

  describe '#image' do
    it 'is not attached by default' do
      image = Image.new
      expect(image.image.attached?).to be false
    end

    it 'attaches an image successfully' do
      image = Image.new(name: "Test Image", user: user)
      image.image.attach(image_file)
      expect(image.image.attached?).to be true
    end
  end
end
