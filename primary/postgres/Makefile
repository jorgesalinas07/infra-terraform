
help: Makefile ## show this help message
	@sed -n 's/^\(.*\):.*## \(.*\)$$/\1 | \2/p' $< | grep -v '@sed' | column -t -s '|'

README.md: header.md footer.md .terraform-docs.yml *.tf ## recompile README.md
	docker run \
		--rm \
		--volume "$$(pwd):/terraform-docs" \
		-u $$(id -u) \
		--platform linux/amd64 \
		quay.io/terraform-docs/terraform-docs:0.18.0 \
		markdown \
		/terraform-docs \
		| tee $@
