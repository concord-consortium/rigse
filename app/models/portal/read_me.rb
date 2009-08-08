class Portal::ReadMe
  
  def initialize
    @readme_path = File.join(RAILS_ROOT, 'vendor', 'plugins', 'portal', 'README.textile')
    @last_changed = File.ctime(@readme_path)
    @html = RedCloth.new(File.read(@readme_path)).to_html
  end
  
  def html
    if File.ctime(@readme_path) > @last_changed
      @last_changed = File.ctime(@readme_path)
      @html = RedCloth.new(File.read(@readme_path)).to_html
    end
    @html
  end

end