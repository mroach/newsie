ELIXIR_VER := 1.10
DOCKER_TAG := newsie_elixir_$(ELIXIR_VER)

.PHONY: test
test:
	mix test

.PHONY: check
check:
	mix format --check-formatted
	mix credo --strict

.PHONY: docker/build
docker/build:
	docker build --tag $(DOCKER_TAG) --build-arg ELIXIR_VER=$(ELIXIR_VER) .

.PHONY: docker/test
docker/test: docker/build
	docker run --rm -v $(PWD):/opt/code $(DOCKER_TAG) mix test

.PHONY: docs
docs:
	mix docs

data/iso-639-3.tab:
	curl -o $(@D)/$(@F) https://iso639-3.sil.org/sites/iso639-3/files/downloads/iso-639-3.tab
