Feature: A teacher uploads an image
  As a Teacher
  I want to be able to easily upload images
  So that I can use them in activities

  Background:
    Given The default project and jnlp resources exist using factories

  Scenario: The teacher creates an image
    Given the following teachers exist:
      | login        | password       |
      | imgteacher   | imgteacher     |
    And I login with username: teacher password: teacher
    When I go to the images page
    And I follow "create Image"
    Then I should see "Upload An Image"
    When I fill in the following:
      | image[name]               | Test Image                                |
      | image[publication_status] | published                                 |
      | image[attribution]        | This is a test image.                     |
      | image[image]              | #{RAILS_ROOT}/public/images/cc-footer.png |
    And I press "image_submit"
    Then I should see "Image was successfully created."
