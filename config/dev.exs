use Mix.Config

config :logger,
  backends: [
    :console,
    {LogstashJson.TCP, :logstash},
    {LogstashJson.Console, :json}
  ]

config :logger, :json, level: :info



config :logger, :logstash,
  level: :debug,
  # host: System.get_env("LOGSTASH_TCP_HOST") || "vs-team-log-test2-23e860018dad5fe8.elb.us-east-1.amazonaws.com",
  host: {:system, "LOGSTASH_TCP_HOST", "vs-team-100-log.galaxyaura.com"},    
  port: System.get_env("LOGSTASH_TCP_PORT") || "4560",
  fields: %{appid: "logstash-json"},
  workers: 2,
  buffer_size: 10_000,
  heart_time: 5_000,
  heart_log_test: true