# NOTE: these should be set in the docker startup environment

ENV['PORTAL_FEATURES'] ||= ''

ENV['REPORT_VIEW_URL'] ||= ''
ENV['REPORT_DOMAINS']  ||= ''

ENV['SCHOOLOGY_CONSUMER_SECRET'] ||= ''
ENV['SCHOOLOGY_CONSUMER_KEY'] ||= ''
