use Mix.Config

config :pear,
  test_api_token: {:system, "SLACK_TEST_API_TOKEN"},
  test_channel: {:system, "SLACK_TEST_CHANNEL"}

config :logger, backends: []
