## Embeddables and Saveables

Embeddables are models representing the widgets embedded in a LARA authored activity. An activity author configures embeddable widgets to appear within the activity and at runtime a user interacts with these widgets to provide responses to the activity. 

Saveables are models representing the runtime state of the embeddable for a running instance of an activity.

During activity runtime, LARA sends json representations of activity responses to portal.

Responses are processed asynchronously by the process_external_activity_data_job

- `app/models/dataservice/process_external_activity_data_job.rb`


See also: `lib/saveable_extraction.rb`



