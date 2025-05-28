# Notes on Image Library and Removal of the Paperclip Gem

We previously used [Paperclip](https://rubygems.org/gems/paperclip/versions/6.1.0) to support an image library feature. This feature allowed teachers in certain projects (e.g., ITSI, WATERS) to upload images for use in authoring custom activities.

## Impact of Ruby on Rails Upgrade

Although the image library feature is no longer actively supported, it remained functional prior to the upgrade to Ruby on Rails 8 in 2025.

Since Paperclip is incompatible with Rails 8, we removed the gem during the upgrade. We intended to migrate the image attachment data to Active Storage, but the [associated migration](https://github.com/concord-consortium/rigse/blob/fa06a88158f8d14829e9dd59e0c1fdaf4851891e/rails/db/migrate/20250226145602_migrate_paperclip_images_to_active_storage.rb) referenced an incorrect local file path and failed.

Despite the failure, there have so far been no reported issues related to this data. Rather than attempting to fix and re-run the migration, we deleted it along with a second migration that would have removed the Paperclip-related columns from the `images` table. As a result, the Paperclip columns still exist in the database.

So if we decide to restore support for the image library in the future, the original image data remains intact. New migrations would be required: one to correctly attach the existing images from S3 to Active Storage, and another to remove the now-obsolete Paperclip columns.

## Image File Storage

Uploaded image files are stored in each Portal instance’s S3 bucket, under a dedicated `images` directory. The following Concord Consortium-owned S3 buckets currently contain such directories:

- `itsi-production` – Used by the now-defunct standalone ITSI portal.
- `nextgen-production` – Used by the production Learn Portal.
- `nextgen-staging` – Used by the staging Learn Portal.

## Removed Migration Code

1. [MigratePaperclipImagesToActiveStorage](https://github.com/concord-consortium/rigse/blob/fa06a88158f8d14829e9dd59e0c1fdaf4851891e/rails/db/migrate/20250226145602_migrate_paperclip_images_to_active_storage.rb)
2. [RemovePaperclipFieldsFromImages](https://github.com/concord-consortium/rigse/blob/fa06a88158f8d14829e9dd59e0c1fdaf4851891e/rails/db/migrate/20250226146000_remove_paperclip_fields_from_images.rb)

## To Do

If the image library feature is officially retired, or an alternative solution for serving images is implemented, the following cleanup steps should be taken:

1. Remove all Paperclip-related columns from the `images` table in the database.
2. Remove or refactor image-related models, controllers, views, routes, and other supporting code.
