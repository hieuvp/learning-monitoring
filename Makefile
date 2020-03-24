# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Standard
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
	$(MAKEFILE_SCRIPT_PATH)/lint-terraform.sh
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


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Prometheus Terraform
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.PHONY: prometheus-terraform-plan
prometheus-terraform-plan:
	cd prometheus-terraform \
	&& terraform plan

.PHONY: prometheus-terraform-apply
prometheus-terraform-apply:
	cd prometheus-terraform \
	&& terraform apply

.PHONY: prometheus-terraform-destroy
prometheus-terraform-destroy:
	cd prometheus-terraform \
	&& terraform destroy
