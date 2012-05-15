class InstallerReport < ActiveRecord::Base

  # some helpers for extracting info out of the body text dump
  def cache_dir
    find /^Writeable cache dir: (.*)$/
  end

  def saved_jar
    find /^Local jar url: (.*)$/
  end

  def local_socket_address
    find /^local_socket_address = (.*)$/
  end

  def local_host_address
    find /^local_host_address = (.*)$/
  end

  def os
    find(/^os.name = (.*)$/) || "Mac"
  end

  def java
    find /^java.runtime.version = (.*)$/
  end

  def using_temp_dir?
    find(/^Writing to a (temp directory)!$/) == "temp directory"
  end

  def already_existed?
    find(/^Local jar already (existed)!$/) == "existed"
  end

  def learner_id
    id = find(/^Not found URL: .*\/portal\/learners\/(\d+).jnlp.*$/)
    return (id ? id.to_i : nil)
  end

  def learner
    lid = learner_id
    l = (lid ? Portal::Learner.find_by_id(lid) : nil)
    puts "Learner id existed: #{lid}, but learner not found (ir: #{self.id})." if !lid.nil? && l.nil?
    return l
  end

  def local_user
    find /^user.name = (.*)$/
  end

  def install_level
    return "failed" unless success
    return (find(/^Trying (temp) folder/) || find(/^Trying (user) folder/) || find(/^Trying (system) folder/))
  end

  # expects a regular expression with at least one capture group.
  # if more than one capture group is present, only the first group value will be reported
  def find(regexp)
    self.body[regexp] ? $1 : nil
  end
end
