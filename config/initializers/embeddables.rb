# Order normally doesn't matter here, but it does for the
# Page model, which uses order to list these alphabetically by display
# name, with "Smartgraphs" embeddables at the end of the list.
# This base list is used by Activity, Investigation, and Section.
BASE_EMBEDDABLES = [
"Embeddable::MultipleChoice",
"Embeddable::OpenResponse",
"Embeddable::Smartgraph::RangeQuestion",
"Embeddable::Xhtml" #displays as "Text"
]

ALL_EMBEDDABLES = BASE_EMBEDDABLES.insert(0, "Embeddable::ImageQuestion")

# This is the full list in order
# [
#     Embeddable::ImageQuestion,
#     Embeddable::MultipleChoice,
#     Embeddable::OpenResponse,
#   ]