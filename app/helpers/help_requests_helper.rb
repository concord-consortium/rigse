module HelpRequestsHelper
  def get_os
    ua = request.env['HTTP_USER_AGENT'].downcase
    if ua.index('windows') or ua.index('win32')
      return 'windows'
    end
    if ua.index('macintosh') or ua.index('mac os x')
      return 'macintosh'
    end
    if ua.index('adobeair')
      return 'adobeair'
    end
    if ua.index('linux')
      return 'linux'
    end
    return 'unknown'
  end
end
