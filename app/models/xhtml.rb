class Xhtml < ActiveRecord::Base
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements


    default_value_for :name, "Collect Data"
    default_value_for :description, <<-HEREDOC
    This sample activity was taken  from "Introduction to Crystals".
    HEREDOC
    
    default_value_for :content, <<-HEREDOC
    <h2>In this activity you will explore aspects of the makeup of crystals.</h2>

    <p>
    Crystals are much sought after by jewelers and 
    industrialists alike. Their value is directly related to their perfection.
    </p>

    <h3>How and why does order exist in a crystal?</h3>
    <p>
    Crystals are common forms of solids. They are characterized by their order,
    compared with the disorder of liquids and the independence of atoms in gases. They are made of repeating units that can be as simple as a single kind of atom or as complex as a protein molecule.
    Imagine we have created a slice through a crystal that is only one atom deep as shown in the model below.<p> 
    <ol>
    <li>
    Run the model by clicking the PLAY arrow at the bottom of the model window.
    Your model has a thermometer inside the model. Run the model and raise the temperature by 
    clicking slowly on the red arrow on the thermometer.
    </li>
    <li>
    Notice how the particles move and the ways in which they are constrained. 
    Then, focus on one atom that is not on the edge, and look at the atoms around it. Repeat for other atoms.
    Pause the model when you see melting.
    </li>
    <li>
    Continue to run the model until you achieve complete melting.
    </li>
    <ol>
    </p>
    HEREDOC
end
