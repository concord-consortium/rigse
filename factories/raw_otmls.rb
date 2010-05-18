Factory.define :raw_otml, :class=> Embeddable::RawOtml do |f|
  f.otml_content "<OTCompoundDoc>\n  <bodyText>\n    <div id='content'>Put your content here.</div>\n  </bodyText>\n</OTCompoundDoc>"
end

