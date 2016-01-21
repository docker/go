GO_VERSION=1.5.3
GO_SRC=/tmp/go/src
PATCH_DIR=$(CURDIR)/patches

.PHONY: clean download_go_src run_patch update docker

define apply_patch
rm -rf $(CURDIR)/$(2);
mkdir -p $(CURDIR)/$(2);
cp -r ${GO_SRC}/$(1)/* $(CURDIR)/$(2)/;
git apply $(PATCH_DIR)/$(3)/*;
endef

download_go_src:
	curl -sSL https://golang.org/dl/go${GO_VERSION}.src.tar.gz | tar -v -C /tmp -xz

run_patch: download_go_src
	$(call apply_patch,encoding/json,canonical/json,json)
	$(call apply_patch,flag,mflag,flag)

update: run_patch clean

docker:
	docker build --rm --force-rm -t jfrazelle/go .

test: docker
	docker run --rm jfrazelle/go go test ./...


clean:
	rm -rf ${GO_SRC}
