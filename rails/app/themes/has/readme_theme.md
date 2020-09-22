Instead of making style sheets, make sass files.

This project uses [themes_for_rails](https://github.com/lucasefe/themes_for_rails) and the 
[rails 3 asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html).

Read the rails guide for more information on the asset pipeline.

Images, Javascripts, and stylesheets for this theme go in `app/assets/themes/<theme-name>/stylesheets/*.sass`
The file `app/assets/themes/<theme-name>/stylesheets/application.sass` should include the 'main' stylesheet references.

    /*
    * =require application
    */

You can then add any other local theme-specific requires using addtional ` =require `  statments. Note to take advantage
of scss variables &etc, instead use the @improt directive (not in comments.)

themes_for_rails is configured in an initialization block under ` config/intializers `

basically its doing this:

    config.themes_dir = ":root/app/assets/themes"
    config.assets_dir = ":root/app/assets/themes/:name"
    config.themes_routes_dir = "assets"

  