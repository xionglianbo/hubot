myservers =
  'staging_admin':
    'stage': 'staging_admin'
    'ec-admin': 'http://ec-admin.nuoxiangcun.com'
    'ec-api': 'http://ec-api.nuoxiangcun.com'

# servers in this array would have effects:
#   + server_dir => `live`
#   + only `master` branch are allowed to deploy
live_servers = [
]

# servers in this array would have effects:
#   + server_dir => `staging`
#   + keep_releases => 30
staging_servers = [
  'staging_admin',
]

module.exports.myservers = myservers
module.exports.live_servers = live_servers
module.exports.staging_servers = staging_servers
