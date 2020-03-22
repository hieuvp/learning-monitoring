.PHONY: fmt
fmt:
	@printf "\n"
	$(MAKEFILE_SCRIPT_PATH)/fmt-shell.sh
	@printf "\n"

	@printf "\n"
	$(MAKEFILE_SCRIPT_PATH)/fmt-terraform.sh
	@printf "\n"

	@printf "\n"
	$(MAKEFILE_SCRIPT_PATH)/fmt-markdown.sh
	@printf "\n"

.PHONY: lint
lint:
	@printf "\n"
	$(MAKEFILE_SCRIPT_PATH)/lint-shell.sh
	@printf "\n"

	@printf "\n"
	$(MAKEFILE_SCRIPT_PATH)/fmt-terraform.sh
	@printf "\n"

.PHONY: git-add
git-add: fmt lint
	@printf "\n"
	git add --all .
	@printf "\n"

.PHONY: clean
clean:
	@printf "\n"
	$(MAKEFILE_SCRIPT_PATH)/clean-terraform.sh
	@printf "\n"

	@printf "\n"
	scripts/clean.sh
	@printf "\n"

.PHONY: terraform-prometheus-apply
terraform-prometheus-apply:
	cd terraform-prometheus \
	&& terraform apply

.PHONY: terraform-prometheus-destroy
terraform-prometheus-destroy:
	cd terraform-prometheus \
	&& terraform destroy
