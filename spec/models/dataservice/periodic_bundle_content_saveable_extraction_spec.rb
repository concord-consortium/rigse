require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::PeriodicBundleContent do
  before(:all) do
    @valid_attributes_with_blob = {
      :periodic_bundle_logger_id => 1,
      :body => B64Gzip.unpack("H4sIAH8iy0wAA+1d227jOBJ9H2D+Qev36H4dOD3ozvQMsOjLopPZfVgsDFqiY01k0atLLn8137BftqR8i2NTKpcdM0LPS7ctk3WKRVaRp0iFw58fZ5l2T4syZfnlwNLNgUbzmCVpfns5+P3m14tw8PO7H38Ysqqo8zstTS4HEydMJiSMLqgTOReWlUwuxjFxL0jkBBNCaDAJxwNeR9OG6WzOiqpsvqy/anFGyvJywIpbPWYcrEj0hXj96811RSr6jbFqoBnganVJC173d/7f1/EfNMZU/kYntOBNp5/J/KDqKa98RYrkiuUVSXNaHFz7mmvMzX846pSlMT242g19hBkoIRW5Lch8qpeiV3jVX/iT38QTMs5gwPtlXLEs441mMFttZGTslkv4eE/z6hO7PUKB949pCa6+VfOaa32Yzas043U/kfGYsbsPdZ4ATbe3/se8Kp4OqX6f0gde/VeWJQd5x6QgM/rAiruVoAduxHnjKh8yNgbJWNi9acDahAV54LHlhrHskFZki9Y/t2NVHeYyOyIaU3IfYuXGZ4fG85A1ZI291vHrWXjSJqyYkeqfi8h5XRVNwBTxc1mYFxeRhUeT9QP+iApM7Y4+XQ6iiWW5lkO7w+i69naU2vptCffiWVNnExab8A3CXdt1LcfYI34429Fiu40T6idx7IUX/iRIFlihNYkvTNOiceSaUUisvxmEh7/7tHoaxTyMjuJVHB2l+T0tq/SWiOg4CgY7UE3ztmLvniK8kPABmoiC5d4C657WCjppprjD9C4XAXy0fmAFuxZc2bFdmaHR1aKh0Rj4lHbfp/9+Yy+nqv1Ni7kGki5AWnil2IuBAbKzVBthYlk7TmdcgOro8RzXBQ8ClSh5Xmsb4qfy3+Z/WszeodtrOeNJlH87vnlIc96Eq87JLX2p7aoRtoVwU/5jyepqekolJ3zmBuolwz5P9Oiw5luLHO3qLkeq8wajBkhxecR4TVRLCaqtBLVtaLydmDyrsyqdZ7w5DfEeeUaaz+tK5o1NoXY3bIqcdEC/1HH5n+V73c4n1aYx8v7mnM66BS3nLC/piM1pPlp/c02JfUUaY3+DKvHL3+vZnHMy7Q8S35XaQ1pNNSpyDkUaa+WcFHfl0Kj2ixDN3Sv9hNM7qwveLSK7MLpdJVQWX+NVbmTkSFq+lYXRnq5YVs9E8m6glVP28D7LrqYkz2nGefCEZCXd1/Ona8oBSq/TPvv7jS7zOjJ/2GR+pEO5RYTo1XYlXs8mxuM66SS3jvhZm6WiJ6Mw1L0o4uxmRh4vB7Zpr76fsyeNp4O0tj3dskI3dJZaW6sH7hnULkVa7hAHavJ4krUGyWp5VJ5kjFTvrChydN/xrKGxeNBa2nF59wWWF4BKL2RHFqz0wbJd3TbNECbb100rjHyoaN7hvg1UO9Ajy/UjGyrb170AJtq1dSs0Tbjaoe6EAay063O1I9cBFeZ2NnXHD2DG9mzdN33fgSnCZdt64Low0aFuR04IK8wle7rtOLDSvqtHdhjB/ICLDritHZj5Akv3fCeCWY+LjnQ38GFDJAj0wPYs2OCzTcvWvRBovtDXbc8Djmsumrtj6MHaGJk69zEbOkAsj3eND9Oau64tRh9YNu/HKPBgHsa9wA2cCOo0VqgHngcMDGKsWg4w6PCJ1NRNz4fqLUZU6ANDAxduccWdCCbcEsGSjyqobBEdbKDi3ILcHVy44o7uODBNLCvSI9OzoQ7PRQeRCQzF3IAicLe2kjNC2fy8WuLtn9tPt+LIyHgkdpBG48Vu3v5VxtaOn2TFy5FT+VJje6tKq9IZva7IbH45+MrXN2NaaHakkUpzfnL8gVY9zenloCEG5UDLWcW/vU8SjTSftYSWcZGOBSeqpnzN1rRa1/V92i/x2c1i30haYndl31AQQcYLln0gxeWgKmpOQFa0dE1bPubi32TNUEhdseuY7P5Ql/QXOiG8vtgzbEQuf6nSKhMNZve0yGe8Odp1PW82ASdcj49JHTcbRyTTbmg8zVnGbp8GWpKW84w8LfYPOUPii9OczA6W02ISbhSxDr2m1WLTtbVoY8Hnm7PS7MuytAGXPVywzG78bUKZFOThsyDIq86LGWeTcfUPlubV+uF9WqZjYf9VmYzxrrH8wLL80JRT0RfGFgNQe1xRWF4vS3P6rzSpppxQiNMoz+ltvBhXGWmAFwI7WrfqDOlqf68xmuJaXs+4j21aYHeDNTJa+cNO6YP4hKQ2kAO0YnfyjdfChvARGTaIn8ihIXxFBg3jL3JsAJ+RVAbyGzk0hO/IsEH8R1IZyIcktYH8SI4N4EsyaBB/kiND+JSkNoxfyaEhfEtSG8a/5NAQPiaDBvEzKTSIr0lqw/ibHBrC5yS1YfxODg3hezJoGP+TY0P4oKQ2kB/KsSF8UYoN4o9SbBCflGLD+KUcHMI3ZeAw/inHhvBRKTaMn8rBAXxVig3ir23Q3XxWhg3htzt15Xx3t2hXbnu7NHRlvJK75ggdFAXAO7o2e9blOjd9NrAgkcP1VgyMFz3flVku0Te7Mnyq8G2PkxYyptnl4IYT9OWXX5vjoZeDLywXJDZPBXN6oqTYu5fyAjmuy4rNfivS5JOQVXa0fNNBnc0aGrDmD5+wVnIs3Q3twPHWu0B8AWN5TrCxEp3NaUGqumg11v/+vFJsKogNuncVNyU70ynDuPX0zrKQotNxizZ0azhkRXqb5iTrzh1hWrKzxdeqLkgX0YfPE20nSMcFq3TcdU7m5ZRVZ83IiQP6zVlv6hMS2SaBnzHfkVYW8btpVc1/MowpKfWMxSRrOqGkxX0aU2PMwUrDcnTxwZiQydhL/FgACjwSmFZk2gF1aeQTZ8wnBy6w3Z+E+n+50eu60exhNGMJzbj2zQkt+wR+JHJtm9c7OpLGm4LrkUpNO25/K6EUGeIPJL67LVidJ8vkY/sAHq+LX7eOvD2mBLlP57IErsBwfRQIOO1ukrbL/KspydY+y+ku87DPc67Pc6yL/OxuHlaWz32RB14OAEjPNO3oRXL2C/mCWu9j63FKiqTSrm4ia3JMJJtzdCzxV4NpoTGDHmG6aAtxkoPUVg1miLati7atCswAjen0ChM7EvqG6aF9pWeYeF9BxwQVmFjPdtDaqsHEzmX4tYkKTPwKw0X7ihrMEB81e4WJX0nho2a/MLGxr2+YKlbjR2CenSP1DlOFbdE18RGsZ5j4ObtXmNhI7R6R/VCCibat0ytMPEP/bjDR0UQJpooxpAATz9AtBVkBFZj42NcvTPyaumeYCsbQEZgKsjwqMPG5GjxHOj+mrYB1qMHEcl78bK8I8+yrVDWY+L0O/BjqGSZ6DKnAxGcKsbuYijBV2LZfmCpsi8bErzC+F0y8r/QLE7uq6R0mOiYowTz7HkDvMPFjSAEmPoOGj31KMBXM2f3CxPuKCkz8WVhszb5h4jlvvzDxnLdfmFgW2TtMBWNIBSZ+LlOBic8Zn38uOwoTb9teYWJHPP40vwpMB32C45i3M1RgYrnDMW/bqMDEv21z/jOFeEz8ySPviNMUKjCxc5l3zGknBZjYlZR3xOm182N66Lmsb5jYjGi/MP0jYkK/MLEzb98wsTPv94OJ5faKMPFrE2RNNZj4GI/VVg0mfiWF5UhqMPErKWxWQA3m+d+x6BsmNifVN0x8jO8XJjZqKsLEZ3l6hYnfscDHBBWY2IyLjX77WA0mfkcRyyIVYeJt2ytM7JsvvcNUYVsFmNhI3TtMFbY9O6Z3xE5bvzDxO+HYNbUaTCwX7Bsmfm2Cz1OrwMSvTbC9ogLTRa8Y+4aJP3mE/+sAKjCxmaW+YeLXYH3C7NvbNnjM848hFZj4M0v4uUwNJjaDdoy2KjDxMQHvZSow8RypB5i9u/1G++tvs3fewfJ61h8aoD+h3wgFXFXA1ewsBbo9ZHH38P6rfp8JkNwV/Ao3F5fLe0lGYdftxeKeXC3O0vjuitV51QzE3Q5+TRWDt6ZiOhNXZvyXh6XmNhDPSPN5XbVr2YyNqyljpeTSjyGdjWmS0OTjKS+Fhl86s31/tNwl4FfQtHsq9GIZd32xDPVNx1V3sQzU0Tu78aUg2ah4tQHrv9UBGyAG7OaGpbczZr3lmB1bJg1MqvQyJOCVPLs333Rfx9N2Y9DpJs5X9qehMSPzrWdC3jc6oQXNY/p568eXIoZGzZE2ZURVPrgr+o2xRZ/wLmosKxTnn/nSK7/jH3/84f/ut+6ae58AAA==")
    }
    
    reset_table_index(Embeddable::OpenResponse, 40)
    reset_table_index(Embeddable::MultipleChoiceChoice, 165)
    reset_table_index(Embeddable::ImageQuestion, 25)
    reset_table_index(Dataservice::Blob, 14)
  end
  
  def reset_table_index(klass, num)
    ActiveRecord::Base.connection.execute('TRUNCATE ' + klass.table_name)
    ActiveRecord::Base.connection.execute("ALTER TABLE #{klass.table_name} AUTO_INCREMENT = #{num}")
  end
  
  it "should extract saveables into separate model objects" do
    blogger = Dataservice::PeriodicBundleLogger.create!()
    student = Portal::Student.create!()
    offering = Portal::Offering.create!()
    learner = Portal::Learner.create!(:bundle_logger_id => blogger.id, :student_id => student.id, :offering_id => offering.id)
    mock_rep_learner = mock(Report::Learner, :update_fields => true)
    Report::Learner.should_receive(:for_learner).exactly(3).times.with(learner,learner,learner).and_return(mock_rep_learner,mock_rep_learner,mock_rep_learner)
    learner.periodic_bundle_logger = blogger
    learner.save!
    blogger.reload
    learner.reload
    blogger.learner.should_not be_nil
    learner.periodic_bundle_logger.should_not be_nil
    @valid_attributes_with_blob[:periodic_bundle_logger_id] = blogger.id
    # create open_response with id = 40
    emb = nil
    begin
      emb = Embeddable::OpenResponse.create!(:name => 'open response', :description => 'open response', :prompt => 'open response?', :default_response => '')
    end until emb.id >= 40

    # create multiple_choice_choice with id = 165
    emb = nil
    begin
      emb = Embeddable::MultipleChoiceChoice.create!(:choice => 'someChoice')
    end until emb.id >= 165
    if emb.multiple_choice.nil?
      mc = Embeddable::MultipleChoice.create!(:name => 'mc', :description => 'mc', :prompt => 'mc prompt?', :user_id => 1)
      emb.multiple_choice = mc
      emb.save!
    end

    # create image_question with id = 25,26
    emb = nil
    begin
      emb = Embeddable::ImageQuestion.create!(:user_id => 1, :name => 'image question 25', :prompt => "Please choose an image")
    end until emb.id >= 26

    bundle_content = Dataservice::PeriodicBundleContent.create!(@valid_attributes_with_blob)

    # create blob with id = 14,15
    emb = nil
    begin
      emb = Dataservice::Blob.create!(:content => 'image', :periodic_bundle_content_id => bundle_content.id)
    end until emb.id >= 15

    bundle_content.periodic_bundle_logger = blogger
    bundle_content.save!
    bundle_content.reload
    blogger.reload
    bundle_content.periodic_bundle_logger_id.should eql(learner.periodic_bundle_logger.id)
    bundle_content.periodic_bundle_logger.learner.id.should eql(learner.id)
    
    bundle_content.extract_saveables.invoke_job
    
    # 1 open response, 1 multiple choice, 2 image questions
    learner.open_responses.size.should eql(1)
    learner.multiple_choices.size.should eql(1)
    learner.image_questions.size.should eql(2)
    learner.open_responses.each do |saveable|
      saveable.answer.should eql('Jumping jacks with electric sparks')
    end
    learner.multiple_choices.each do |saveable|
      saveable.answers.size.should eql(1)
      saveable.answers[0].answer.should eql('someChoice')
    end
    learner.image_questions.each do |saveable|
      bundle_content.blobs.include?(saveable.answer).should be_true
    end
  end

end
