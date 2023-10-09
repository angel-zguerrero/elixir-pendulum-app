###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM elixir As development

WORKDIR /usr/src/app

COPY --chown=elixir:elixir . .
RUN mix deps.get --only prod

USER elixir

###################
# BUILD FOR PRODUCTION
###################

FROM elixir As build

WORKDIR /usr/src/app

# In order to run `npm run build` we need access to the Nest CLI which is a dev dependency. In the previous development stage we ran `npm ci` which installed all dependencies, so we can copy over the elixir_modules directory from the development image
COPY --chown=elixir:elixir --from=development /usr/src/app/deps ./deps

COPY --chown=elixir:elixir . .

# Run the build command which creates the production bundle

ENV MIX_ENV prod

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix compile --force
RUN mix release orchestrator --force
RUN mix release executor --force


# MIX_ENV=prod mix local.hex --force
# MIX_ENV=prod mix local.rebar --force
# MIX_ENV=prod mix compile --force
# MIX_ENV=prod mix release orchestrator --force

USER elixir


###################
# PRODUCTION
###################

FROM elixir As production

# Copy the bundled code from the build stage to the production image
COPY --chown=node:node --from=build /usr/src/app/deps ./deps
COPY --chown=node:node --from=build /usr/src/app/rel ./rel
COPY --chown=node:node --from=build /usr/src/app/_build ./_build

#_build/prod/rel/orchestrator/bin/orchestrator start

# Start the server using the production build
CMD ["sh", "-c", "_build/prod/rel/${APP_TYPE}/bin/${APP_TYPE} start"]