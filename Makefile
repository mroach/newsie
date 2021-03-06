ELIXIR_VER := 1.10
DOCKER_TAG := newsie_elixir_$(ELIXIR_VER)

.PHONY: all test test-watch check docker/build docker/test docs clean

all: priv/data/iso-639-3.tab priv/data/iso-3166.tab test check

test:
	mix test

test-watch:
	env MIX_ENV=test mix test.watch

check:
	mix format --check-formatted
	env MIX_ENV=test mix credo --strict
	env MIX_ENV=test mix dialyzer --quiet

docker/build:
	docker build --tag $(DOCKER_TAG) --build-arg elixir_ver=$(ELIXIR_VER) .

docker/test: docker/build
	docker run --rm -v $(PWD):/opt/code $(DOCKER_TAG) mix test

docs:
	mix docs

clean:
	rm priv/data/iso-639-3.tab
	rm priv/data/iso-3166.tab

priv/data/iso-639-3.tab:
	curl -Sso $(@D)/$(@F) https://iso639-3.sil.org/sites/iso639-3/files/downloads/iso-639-3.tab

priv/data/iso-3166.tab:
	curl -Sso $(@D)/$(@F) https://data.iana.org/time-zones/tzdb/iso3166.tab
