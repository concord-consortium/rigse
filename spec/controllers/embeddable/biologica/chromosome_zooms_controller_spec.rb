require 'spec_helper'

describe Embeddable::Biologica::ChromosomeZoomsController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_biologica_chromosome_zoom
    with_tag('OTChromosomeZoom') do
      with_tag('organisms')
    end
  end

end

# <OTChromosomeZoom chromosomeAVisible='true' chromosomeBVisible='true' 
#   chromosomePositionInBasePairs='0' chromosomePositionInCM='0.0' drawCrossover='false' drawGenes='true' 
#   drawMarkers='false' drawTracks='false' gBrowseURLTemplate='' imageLabelCharacteristicsTextVisible='false' 
#   imageLabelLockSymbolVisible='false' imageLabelNameTextVisible='true' imageLabelSexTextVisible='true' imageLabelSize='2' 
#   imageLabelSpeciesTextVisible='false' local_id='chromosome_zoom_2' organismLabelType='0' zoomLevel='0'>
#   <organisms>
#   </organisms>
# </OTChromosomeZoom>
