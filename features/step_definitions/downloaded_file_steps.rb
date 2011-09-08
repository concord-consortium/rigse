Then /^the jnlp should not be cached$/ do
  headers = page.driver.response.headers
  headers.should have_key 'Pragma'
  # note: there could be multiple pragmas, I'm not sure how that will be returned and wether this will correclty match it
  headers['Pragma'].should match "no-cache"
  headers.should have_key 'Cache-Control'
  headers['Cache-Control'].should match "max-age=0"
  headers['Cache-Control'].should match "no-cache"
end
