# Elixir Pendulum App

Pleasant River microservice (fictitious but functional) this distributed application solves complex mathematical calculations using the power of erlang OTP. Each mathematical operation calculation is distributed among several nodes within the same cluster, where each of them will solve a part of the problem and finally the result will be stored in Rabbitmq.

The operations coming from the [Node Tyrant Api](https://github.com/angel-zguerrero/node-tyrant-api).

Written in Elixir using Rabbitmq as a backend to store the solution of the operations, Redis as communication and discovery layer between the nodes.


## ▶️ See in action

You can see all the ecosystem in action of this this distributed service deploying [Distributed Hive Network](https://github.com/angel-zguerrero/hive-docker/blob/main/distributed-hive-network).


## 🛠 Tech Stack

- [Elixir](https://elixir-lang.org)
- [RabbitMQ](https://www.rabbitmq.com)
- [Redis](https://redis.io)

## 👨🏻‍💻 Techniques

- [Publish / Subscribe Pattern (Redis Adapter)](https://hexdocs.pm/phoenix_pubsub_redis/Phoenix.PubSub.Redis.html)
- [Server-side Service Discovery](https://microservices.io/patterns/server-side-discovery.html)
- [OTP](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html)
- [Aggregation Pattern](https://www.ibm.com/docs/en/baw/19.x?topic=aggregation-patterns)
- [Docker Container](https://www.docker.com/resources/what-container)

## Installation

```bash
$ mix deps.get
```

## Configuring the app

Edit ***./config/config.exs*** file to use your own ENV VARS to configure Redis, Rabbitmq and the Application itself.

## Running the app

```bash
# to start the orchestrator
$ cd ./apps/scientific_calculator_orchestrator
$ iex --sname orchstrator0  -S mix

# to start the executors, you can add as many as you want
$ cd ./apps/scientific_calculator_executor
$ iex --sname ex0 -S mix
$ iex --sname ex1 -S mix
$ iex --sname ex2 -S mix

```

## How to use

### Send operation to resolve

#### Factorial request

You can use [Node Tyrant Api](https://github.com/angel-zguerrero/node-tyrant-api) to process a factorial operation or you can send a message directly to the queue configured in the ENV VAR RABBITMQ_SCIENTIST_OPERATIONS_TO_SOLVE_QUEUE (default is "scientist-operations-to-solve") Example:

```javascript
{
        "pattern": "scientist-operations-to-solve",
        "data": {
          "operation": {
            "type": "factorial",
            "value": 30
          },
          "status": "pending",
          "ttl": "2023-09-20T12:23:21.676Z",
          "_id": "650997ac5a6800bff0e6ef80",
          "createdAt": "2023-09-19T12:44:28.442Z",
          "updatedAt": "2023-09-19T12:44:28.442Z",
          "__v": 0
        },
        "id": "dd7364ba72958ebcdedd5"
      }
```

#### Factorial response

The response will be storage into the queue configured in the ENV VAR RABBITMQ_SCIENTIST_OPERATIONS_SOLVED (default is "scientist-operations-solved") Example:

```javascript

{
  "status": "success",
  "result": {
    "execution_time": 1,
    "executors": [
      "ex2@8905041f38c2 - <0.246.0>",
      "ex1@8905041f38c2 - <0.247.0>",
      "ex0@8905041f38c2 - <0.247.0>"
    ],
    "operation_name": "factorial",
    "parameters": {
      "m": 1,
      "n": 30
    },
    "result": {
      "value": 265252859812191058636308480000000
    }
  },
  "_id": "650997ac5a6800bff0e6ef80"
}

```

## Docker

This application can be easily run on Docker. You can use `Dockerfile` to create and push the image to a Docker repository for use in a production environment.

You can run this application and its services using the `compose-file.yaml` docker.

```bash
$ docker-compose up --build
```

## Author

[@angel-zguerrero](https://github.com/angel-zguerrero)
