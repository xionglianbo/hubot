# Commands:
#   hubot status [<repository>] - Give deployment status for <repository>.
#   hubot deploy <repository> <environment> [[<remote>/]<branch>] - Deploy <repository> to <environment>, or <branch> if any.
#
# Notes:
#   - repository:  Github repository name for the project to be deployed.
#   - environment: `LIVE` or `staging`.
#   - remote:      Github username.
#   - branch:      branch to deploy on the environment.

func     = require '../lib/func.coffee'
projects = require '../config/projects.coffee'
servers  = require '../config/servers.coffee'
str_pad  = func.str_pad

process.env.PATH = '/usr/local/rvm/gems/ruby-2.2.0/bin:/usr/local/rvm/rubies/ruby-2.2.0/bin:' + process.env.PATH
process.env.GEM_PATH = "/usr/local/rvm/gems/ruby-2.2.0:/usr/local/rvm/gems/ruby-2.2.0@global"

module.exports = (robot) ->

  # Post message to Slack.
  post_to_slack = (msg, post_string) ->
    # Avoid SlackRTMError when post_string is empty
    if post_string.length is 0
        return
    msg.send post_string

  # Post message to specific Slack channel.
  post_to_project_channel = (msg, project, post_string) ->
    data = {
      text: post_string,
      parse: 'none',
      link_names: 1
    }

    if project in [
        'ec-admin',
        'ec-api'
    ]
      data.channel = ''

    # msg.http(process.env.HUBOT_SLACK_WEBHOOK_URL).post(JSON.stringify data)

  # Deploy Hubot himself.
  robot.respond /deploy\s+hubot\s*$/i, (msg) ->
    post_to_slack msg, "I am gonna be reborn in 30 seconds, sit tight :)"

    @exec = require('child_process').exec
    procs = []
    command = "cd /home/ec2-user/hubot && git pull && sleep 5 && sudo /usr/local/bin/supervisorctl restart hubot"

    procs.push {ret: @exec(command)}

  # Get project deployment status
  robot.respond /status(?:\s+)(?:http:\/\/)?(\S+)(?:\s*)$/i, (msg) ->
    project_and_url = msg.match[1].trim().split ' '
    project = project_and_url[0]
    if not projects[project]
      post_to_slack msg,'wrong project'
      return

    server_name_len = 12

    _data = robot.brain.data.mystatus

    rows = []
    rows.push  "\n#{str_pad('Server',server_name_len)}\t#{str_pad('Branch',15)}\t#{str_pad('Deploy Time',11)}"
    for group_key of projects[project]
      for server in projects[project][group_key]
        if _data[server] && _data[server][project]
          #msg.send _data[server][project]['status']
          branch = _data[server][project]['branch']
          time = _data[server][project]['time']
          rows.push "#{str_pad(server,server_name_len)}\t" + "#{str_pad(branch,15)}\t" + str_pad(time, 11)
        else
          rows.push "#{str_pad(server,server_name_len)}\t" + "#{str_pad('---',15)}\t" + str_pad('---', 11)

    #for staging
    for server of servers.myservers
      if server.substr(0, 7) == 'staging'
        if _data[server] && _data[server][project]
          branch = _data[server][project]['branch']
          time = _data[server][project]['time']
          rows.push "#{str_pad(server,server_name_len)}\t" + "#{str_pad(branch,15)}\t" + str_pad(time, 11)

    post_to_slack msg,rows.join("\n")

  # Handle deployment tasks
  robot.respond /deploy(?:\s+)(?:http:\/\/)?(\S+)(?:\s+)(\w+)(?:\s*)(\S*?)$/i, (msg) ->
    # 0                    1             2                 3
    # deploy (white space) project (w s) environment (w s) (remote/branch)

    project = msg.match[1]
    env = msg.match[2] # Environment: LIVE/staging

    if msg.match[3]
      branch = msg.match[3]
    else
      branch = 'master'

    if branch.search('/') > 0
      [remote_name, branch_name] = branch.split '/'
    else
      remote_name = 'origin'
      branch_name = branch

    _data = robot.brain.data.mystatus ||={}

    if not projects[project]
      post_to_slack msg,'wrong project'
      return

    if projects[project][env]
      deploy_servers = projects[project][env]
    else
      if not servers.myservers[env]
        post_to_slack msg,'wrong server'
        return
      deploy_servers = [env]

    #procs for hold exec handler
    that = @
    @exec = require('child_process').exec
    procs = []

    #check all the servers
    for server in deploy_servers
      if server in servers.live_servers && branch != 'master'
        post_to_slack msg,"live servers support 'master' branch only!"
        return

      if servers.myservers[server][project]
        url = servers.myservers[server][project]
      else
        post_to_slack msg,"server `#{server}` do not support project `#{project}`"
        return

    deploy_main = () ->
      #start deploy, push exec handler to procs
      for server in deploy_servers
        stage = servers.myservers[server]['stage']

        # define server_dir, default to server
        server_dir = server
        if server in servers.live_servers
          server_dir = 'live'
        if server in servers.staging_servers
          server_dir = 'staging'

        keep = 10

        post_to_slack msg,"deploying project: `#{project}` branch: `#{branch}` to server: `#{server}`, sit tight...:octocat:"

        command = "cd ~/capistrano; cap server=#{server_dir} project=#{project} branch=#{branch} keep_releases=#{keep} #{stage} deploy"

        timestr = new Date().format("MM-dd HH:mm")
        if not _data[server]
          _data[server] = {}

        _data[server][project] = {"status": "deploying", "user": msg.message.user.name, "branch": branch, "time": timestr}
        robot.brain.data.mystatus = _data
        procs.push {ret: that.exec(command), server: server, project: project}

      # Handle std result of procs
      i = 0
      while i < procs.length
        ((proc) ->
          error_chunks = []
          proc.ret.stdout.on 'data', (chunk) ->
            # Can be used to send all output to Slack
            #msg.send chunk.toString()
          proc.ret.stderr.on 'data', (chunk) ->
            error_chunks.push chunk.toString()
          proc.ret.on 'exit', (code, signal) ->
            server = proc['server']
            project = proc['project']
            url = servers.myservers[server][project]

            if code == 0
              robot.brain.data.mystatus[server][project]['status'] = 'deployed'

              # Change the URL from http://origin.url to http://{{ prefix }}.origin.url
              # prefix is based on remote and branch
              # and should only work on staging environment
              if env == 'staging' and (branch.search '/') > 0
                remote_and_branch = branch.split '/'
                remote = remote_and_branch[0]
                remote_branch = remote_and_branch.slice(1).join '/'
                if remote != 'xiong'
                  if remote_branch != 'master'
                    prefix = remote_branch.toLowerCase()
                  else
                    prefix = remote.toLowerCase()

                  url = url.replace /:\/\//, "://#{prefix}."

              post_to_slack msg,"successfully deployed on `#{server}`\n#{url}"
              # post back to Slack channel if deploying to production
              if server_dir == 'live'
                post_to_project_channel msg,project,"@#{msg.message.user.name} deployed `#{project}/#{branch}` on `#{server}`"
            else
              post_to_slack msg,"`oops! #{msg.message.user.name}, Project #{project} deploy failed on server #{server}`"
              post_to_slack msg,error_chunks.pop()
        ) procs[i]
        i++

    return deploy_main()
