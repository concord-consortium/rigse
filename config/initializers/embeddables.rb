# Order normally doesn't matter here, but it does for the
# Page model, which uses order to list these alphabetically by display
# name, with "Smartgraphs" embeddables at the end of the list.
# This base list is used by Activity, Investigation, and Section.
BASE_EMBEDDABLES = [ 
"Embeddable::DataTable",
"Embeddable::DrawingTool",
"Embeddable::DataCollector",
"Embeddable::InnerPage",
"Embeddable::MwModelerPage",
"Embeddable::MultipleChoice",
"Embeddable::NLogoModel",
"Embeddable::OpenResponse",
"Embeddable::Smartgraph::RangeQuestion",
"Embeddable::LabBookSnapshot", #displays as "Snapshot"
"Embeddable::RawOtml",
"Embeddable::Xhtml" #displays as "Text"
]

# These additional embeddables are used by Page (which also sometimes removes RawOtml)
ALL_EMBEDDABLES = BASE_EMBEDDABLES.insert(3, "Embeddable::ImageQuestion").insert(11, "Embeddable::SoundGrapher").insert(14, "Embeddable::VideoPlayer")

# This is the full list in order
# [
#     Embeddable::DataTable,
#     Embeddable::DrawingTool,
#     Embeddable::DataCollector,
#     Embeddable::ImageQuestion,
#     Embeddable::InnerPage,
#     Embeddable::MwModelerPage,
#     Embeddable::MultipleChoice,
#     Embeddable::NLogoModel,
#     Embeddable::OpenResponse,
#     Embeddable::Smartgraph::RangeQuestion,
#     Embeddable::LabBookSnapshot, #displays as "Snapshot"
#     Embeddable::SoundGrapher,
#     Embeddable::Xhtml, #displays as "Text"
#     Embeddable::VideoPlayer
#   ]