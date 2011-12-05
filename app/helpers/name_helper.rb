module NameHelper
  @namer = LocalNames.instance(APP_CONFIG[:theme])

  def local_name_for(object,default)
    @namer.local_name_for(object,default)
  end

end
