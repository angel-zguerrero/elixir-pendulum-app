# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]
#

config :scientific_calculator_executor,
  limit_factorial: 10_000_000

config :scientific_calculator_orchestrator,
  rabbitmq_url: System.get_env("RABBITMQ_URL") || "amqp://admin:admin@pendulum-app-rabbitmq:5672",
  rabbitmq_scientist_operations_to_solve_queue: System.get_env("RABBITMQ_SCIENTIST_OPERATIONS_TO_SOLVE_QUEUE") || "scientist-operations-to-solve",
  rabbitmq_scientist_operations_solved: System.get_env("RABBITMQ_SCIENTIST_OPERATIONS_SOLVED") || "scientist-operations-solved",
  debug_logging: true

config :scientific_calculator_pubsub,
  redis_host: System.get_env("REDIS_HOST") || "pendulum-app-redis",
  redis_port: System.get_env("REDIS_PORT") || 6379
