# Elixir Pendulum App

Pleasant River microservice (fictional but functional) that solves complex mathematical calculations using the power of the erlang otp. Each mathematical operation calculation is distributed among several nodes within the same cluster, where each of them will solve a part del problema and finally the final result will be stored in rabbitmq.

The operations coming from the [Node Tyrant Api](https://github.com/angel-zguerrero/node-tyrant-api).

Written in Elixir using Rabbitmq as a backend to store the solution of the operations, Redis as communication and discovery layer between the nodes.


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
