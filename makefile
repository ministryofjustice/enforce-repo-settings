IMAGE := ministryofjustice/enforce-repository-settings:1.0

.built-image: bin/* lib/* Dockerfile makefile
	docker build -t $(IMAGE) .
	docker push $(IMAGE)
	touch .built-image

build: .built-image
