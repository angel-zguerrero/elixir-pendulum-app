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

USER elixir


###################
# PRODUCTION
###################

FROM elixir As production

# Copy the bundled code from the build stage to the production image
COPY --chown=elixir:elixir --from=build /usr/src/app/deps ./deps
COPY --chown=elixir:elixir --from=build /usr/src/app/rel ./rel
COPY --chown=elixir:elixir --from=build /usr/src/app/_build ./_build


# Start the server using the production build
CMD ["sh", "-c", "_build/prod/rel/${APP_TYPE}/bin/${APP_TYPE} start"]