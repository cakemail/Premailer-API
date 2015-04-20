# vim: set noexpandtab ts=2 :
NAME = docker.r53.wbsrvc.com/premailer
tag = $(shell git rev-parse --abbrev-ref HEAD).$(shell date +%Y%m%d%H%M%S)
dockertag = $(shell date +%Y%m%d%H%M%S)-$(shell git rev-list HEAD | head -1)-$(shell whoami)-at-$(shell hostname)
jira_username = $(JIRA_USERNAME)
jira_password = $(JIRA_PASSWORD)

build:
	@if ! test -n "$(jira_username)"; then echo "please export your JIRA username to JIRA_USERNAME"; false; fi
	@if ! test -n "$(jira_password)"; then echo "please export your JIRA password to JIRA_PASSWORD"; false; fi
	@git diff --exit-code || false

	@if ! test -n "$(jira)"; then echo "You must specify the JIRA issue related to this deployment"; false; fi
	@echo "Checking JIRA issue..."
	@if ! `curl -f -s -u '$(jira_username):$(jira_password)' -X GET -H "Content-Type: application/json" https://jira.cakemail.com/rest/api/2/issue/$(jira)/comment >/dev/null`; then echo "Issue $(jira) invalid"; false; fi
	@echo "Building docker image..."
	@docker build -t $(NAME):$(dockertag) . >> .make.log
	@echo "Pushing to branch $(shell git rev-parse --abbrev-ref HEAD)..."
	@git push origin $(shell git rev-parse --abbrev-ref HEAD) >> .make.log
	@echo "Tagging $(tag).."
	@git tag $(tag) >> .make.log
	@echo "Pushing tag $(tag).."
	@git push origin $(tag) >> .make.log
	@echo "Commenting the JIRA issue $(jira)..."
	@curl -f -s -u '$(jira_username):$(jira_password)' --data '{ "body": "IMAGE TAG: Docker image *$(NAME):$(dockertag)* built, tagged in git to *$(tag)*" }' -X POST -H "Content-Type: application/json" https://jira.cakemail.com/rest/api/2/issue/$(jira)/comment >/dev/null
	@echo "Done."
	@echo $(dockertag) > ./.tagfile
	@echo $(jira) >> ./.tagfile

push:
	@echo "Checking JIRA issue..."
	@if ! `curl -f -s -u '$(jira_username):$(jira_password)' -X GET -H "Content-Type: application/json" https://jira.cakemail.com/rest/api/2/issue/$(shell cat ./.tagfile | tail -1)/comment >/dev/null`; then echo "Issue $(shell cat ./.tagfile | tail -1) invalid"; false; fi
	@echo "Pushing image [$(NAME):$(shell cat ./.tagfile | head -1)] to registry..."
	@docker push $(NAME):$(shell cat ./.tagfile | head -1) >> .make.log
	@echo "Commenting the JIRA issue $(shell cat ./.tagfile | tail -1)..."
	@curl -f -s -u '$(jira_username):$(jira_password)' --data '{ "body": "IMAGE PUSHED: Docker image *$(NAME):$(dockertag)* pushed to the registry, ready for deployment" }' -X POST -H "Content-Type: application/json" https://jira.cakemail.com/rest/api/2/issue/$(shell cat ./.tagfile | tail -1)/comment >/dev/null
	@echo "Done."

