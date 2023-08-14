require 'net/http'
require 'net/https'
require 'multi_json'
require 'cgi'
require 'openssl'
require 'pry'

require "livechat/version"
require 'livechat/util'
require 'livechat/V3.5/rest/errors'
require 'livechat/V3.5/rest/utils'
require 'livechat/V3.5/rest/list_resource'
require 'livechat/V3.5/rest/instance_resource'
require 'livechat/V3.5/rest/agents'
require 'livechat/V3.5/rest/canned_responses'
require 'livechat/V3.5/rest/chats'
require 'livechat/V3.5/rest/goals'
require 'livechat/V3.5/rest/groups'
require 'livechat/V3.5/rest/reports'
require 'livechat/V3.5/rest/status'
require 'livechat/V3.5/rest/visitors'
require 'livechat/V3.5/rest/client'

$HOST = "https://api.livechatinc.com/"
$API_VERSION = 3.5

def endpoint_path(section, endpoint, api_version = $API_VERSION)
  valid = ['agent', 'configuration', 'customer'].include?(section)
  raise Exception unless valid
  $HOST + "v#{api_version}/#{section}/action/" + endpoint
end