ELIXIR_VER := 1.10
DOCKER_TAG := newsie_elixir_$(ELIXIR_VER)

.PHONY: test
test:
	env MIX_ENV=test mix test

.PHONY: test-watch
test-watch:
	env MIX_ENV=test mix test.watch

.PHONY: check
check:
	mix format --check-formatted
	env MIX_ENV=lint mix credo --strict
	env MIX_ENV=lint mix dialyzer --quiet

.PHONY: docker/build
docker/build:
	docker build --tag $(DOCKER_TAG) --build-arg ELIXIR_VER=$(ELIXIR_VER) .

.PHONY: docker/test
docker/test: docker/build
	docker run --rm -v $(PWD):/opt/code $(DOCKER_TAG) mix test

.PHONY: docs
docs:
	env MIX_ENV=docs mix docs

data/iso-639-3.tab:
	curl -o $(@D)/$(@F) https://iso639-3.sil.org/sites/iso639-3/files/downloads/iso-639-3.tab

data/iso-3166.tab:
	curl -o $(@D)/$(@F) https://data.iana.org/time-zones/tzdb/iso3166.tab
