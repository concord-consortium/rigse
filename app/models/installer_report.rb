class InstallerReport < ActiveRecord::Base

  # some helpers for extracting info out of the body text dump
  def cache_dir
    find /^Writeable cache dir: (.*)$/
  end

  def saved_jar
    find /^Local jar url: (.*)$/
  end

  def local_address
    find /^local_socket_address = (.*)$ /
  end

  def using_temp_dir?
    find(/^Writing to a (temp directory)!$/) == "temp directory"
  end

  def learner
    learner_id = find(/^Not found URL: .*\/portal\/learners\/(\d+).jnlp.*$/)
    l = nil
    l = Portal::Learner.find(learner_id.to_i)
    return l
  end

  # expects a regular expression with at least one capture group.
  # if more than one capture group is present, only the first group value will be reported
  def find(regexp)
    self.body[regexp] ? $1 : "not found"
  end
end
